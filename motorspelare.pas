unit MotorSpelare;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Spelare,StdCtrls, Process, kommunikation, Dialogs,
  Spelregler, Globals, Forms;

type

  TMotorSpelare= Class(TSpelare)
  private
      FReady:boolean;
      FProcess:TProcess;
      FBetankeTid:integer; //millisekunder
      Bestmove:TMove;
      Procedure Parse(input:string);
      Procedure SetBestMove(input:string);
      Procedure ReadOutput;
  Public

      //Visuella komponenter FÖR KOMMUNIKATIONEN
      //den e kopplad till. nil-a dem för att inte få visuell output
      //VName: TCustomLabel;  Denna är delad med TSpelare
      //Dessa är mest för debugging, används ej i slutprodukten
      VAuthor:TCustomLabel;

      VBest:TCustomLabel;

      VNodes:TCustomLabel;
      VScore:TCustomLabel;
      VPv:TCustomLabel;
      VNPS:TCustomLabel;
      VDepth:TCustomLabel;
      VCurrMove:TCustomLabel;
      VCurrMoveNumber:TCustomLabel;

      VMultiPv:TCustomMemo;

      VAlloutput:TCustomMemo;
      VAllunprocessed:TCustomMemo;

      Function IsReady:boolean;
      Property Process:TProcess read FProcess;
      Property Betanketid:Integer read FBetanketid;

      Function Get_move:TMove; override;


      Constructor Create;
      Destructor Destroy; override;
  end;


implementation

Constructor TMotorSpelare.Create;
begin
      {
      //Visuella komponenter den e kopplad till. nil-a dem för att inte få visuell output
      VAuthor:=nil;

      VBest:=nil;

      VNodes:=nil;
      VScore:=nil;
      VPv:=nil;
      VNPS:=nil;
      VDepth:=nil;
      VCurrMove:=nil;
      VCurrMoveNumber:=nil;

      VMultiPv:=nil;

      VAlloutput:=nil;
      VAllunprocessed:=nil;
      }

      FBetankeTid:=500;

      //Globals.LystnandeProcesser.Add(self);
end;

Destructor TMotorSpelare.Destroy;
begin
  FProcess.Free;
end;

Function TMotorSpelare.get_move:TMove;
var
tid:TDateTime;
begin
if Is_Null_Turn(Parti.State) then
   exit(NullMove);

    {
     if not IsReady then begin
     	ShowMessage('Motorn ej redo!');
        end;
    }
    BestMove:=UndefinedMove;

    try
      kommunikation.StartaProcess(Process, Motorpath);

      kommunikation.Skickadata(Process,'position '+Babupos(parti.state));
      kommunikation.Skickadata(Process,'go time '+inttostr(Betanketid));
      sleep(100);

      tid:=Now;

      while (Bestmove=UndefinedMove) and ((Now-tid)<(Betanketid+2000)/MSecsPerDay) do begin
      	  sleep(100);
          ReadOutput;
          Application.ProcessMessages;
      end;
    finally
      kommunikation.Avbryt_o_nil_process(Process);
    end;

    if Bestmove=UndefinedMove then begin
       ShowMessage('Motorn svara inte i get_move()');
       result:=Self.Get_move;
       end
    else
    	result:=Bestmove;
end;


Function TMotorSpelare.Isready:boolean;
begin
{
{$IFDEF WINDOWS}
     exit(true);
{$ENDIF}
}
     if not Process.Running then begin
        showmessage('Processen körs inte ens (TMotorSpelare.Isready)');
        exit(false);
        end;

     FReady:=false;

     try
       kommunikation.StartaProcess(Process, Motorpath);
       kommunikation.Skickadata(Process,'isready');
       sleep(100);
       ReadOutput;
     finally
       kommunikation.Avbryt_o_nil_process(Process);
     end;

     result:=FReady;
end;

//kommunikation.Skickadata(Process,Babupos(state));


Procedure TMotorSpelare.Parse(input:string);
var
s,s2,s3: string;
sl: TStringlist;

unparseable:boolean;

atline :integer;

a:integer;

i,j:integer;


begin
if VAlloutput<>nil then
   VAlloutput.Clear;
sl:=TStringList.Create;
//showmessage(input);

unparseable:=false;

j:=1;
for i := 1 to length(input) do begin
    if (input[i]=' ') then begin
       s:=copy(input,j,i-j);
       if (s<>'') and (s<>' ') then
       	  sl.Add(s);
       j:= i + 1;
       end
    else if Copy(input,i,length(LineEnding))=LineEnding then begin //i Windows är LineEnding flera tecken
      s:=copy(input,j,i-j);
      if (s<>'') and (s<>' ') then
      	 sl.Add(s);
      j:= i + Length(LineEnding);

      s:='';
      for a:=0 to sl.Count-1 do
          s+=sl[a]+' ';

      if VAlloutput<>nil then
      	 VAlloutput.Append(s);

      atline:=0;

      while (atline<sl.Count) and not unparseable do begin

            if atline<>0 then
               ShowMessage('Varning, motorn skicka flera kommandon på samma rad!');

      	    s:=sl[atline];
            inc(atline);


            if s='bestmove' then begin

               s:=sl[atline];
               inc(atline);

               if VBest<>nil then
                  VBest.Caption:='Bästa: '+s;

//EJ KLART!!! Måste fixa hur den ska föra vidare draget etc.
     	       self.SetBestMove(s);
               //self.MakeBestMove;

       	       end
       	    else
       	    if s='readyok' then begin
               FReady:=true;
       	       end
            else
            if s='id' then begin

               s2:=sl[atline];
               inc(atline);

               s3:='';

               for atline:=atline+1 to sl.Count do
                     s3+=sl[atline-1]+' ';


               if (s2='author') and (VAuthor<>nil) then
                  VAuthor.Caption:='Author: '+s3

	       else if (s2='name') and (VNamn<>nil) then
                  VNamn.Caption:='EngineName: '+s3;


               end // if s='id'
            else
            if s='info' then begin

               while (atline<sl.Count) and not unparseable do begin

               	     s:=sl[atline];
               	     inc(atline);

                     if s='depth' then begin
                     	s:=sl[atline];
		     	inc(atline);
                        if VDepth<>nil then
                     	   VDepth.Caption:='Depth: '+s;
                        end else

                     //Time ej implementerat eller stött

                     if s='nodes' then begin
                     	s:=sl[atline];
		     	inc(atline);
                        if VNodes<>nil then
                     	   VNodes.Caption:='Nodes: '+s;
                        end else

                     if s='pv' then begin
                     	s:=sl[atline];
		     	inc(atline);
                        if VPv<>nil then
                     	   VPv.Caption:='PV: '+s;
                        end else

                     if s='multipv' then begin
                     	inc(atline);
                        end else
//EJ KLART!
                     if s='nodes' then begin
                     	s:=sl[atline];
		     	inc(atline);
                        if VNodes<>nil then
                     	   VNodes.Caption:='Nodes: '+s;
                        end else

                     if s='score' then begin
                        s2:='';

                        for a:=1 to 4 do begin
                     	    s:=sl[atline];
		     	    inc(atline);
                            s2+=s+' ';
                            end;
                        if VScore<>nil then
                     	   VScore.Caption:='Score: '+s2;
                        end else

                     if s='nps' then begin
                     	s:=sl[atline];
		     	inc(atline);
                        if VNPS<>nil then
                     	   VNPS.Caption:=s+'n/s';
                        end else

                     if s='currmove' then begin
                     	s:=sl[atline];
		     	inc(atline);
                        if VCurrMove<>nil then
                     	   VCurrMove.Caption:='Tänker på: '+s;
                        end else


                     if s='currmovenumber' then begin
                     	s:=sl[atline];
		     	inc(atline);
                        if VCurrMoveNumber<>nil then
                     	   VCurrMoveNumber.Caption:='Tänker på #: '+s;
                        end else

                     begin
                        unparseable:=true;
                        end;

                     end;// while (atline<sl.Count) and not unparseable do begin
               end
            else begin
               unparseable:=true;
               end;
	    end; // while (atline<sl.Count) and not unparseable do begin

      if unparseable and (VAllunprocessed<>nil) then
      	 for a:=atline-1 to sl.Count-1 do
             VAllunprocessed.Append(sl[a]);

      sl.Clear;
      unparseable:=false;
      end;
    end;// för forsatsen
end;

Procedure TMotorSpelare.SetBestMove(input:string);
begin
if input <> '0000' then begin
   self.Bestmove.nullmove:=false;
   self.Bestmove.from.x:=ord(input[1])-ord('a');
   self.Bestmove.from.y:=ord(input[2])-ord('1');
   self.Bestmove.moveto.x:=ord(input[3])-ord('a');
   self.Bestmove.moveto.y:=ord(input[4])-ord('1');
end else
    self.Bestmove.nullmove:=true;

end;

procedure TMotorSpelare.ReadOutput;
var
  NoMoreOutput: boolean;
  i:		IntegeR;

  procedure DoStuffForProcess(MotorSpelare:TMotorSpelare);
  var
    Buffer: string;
    BytesAvailable: DWord;
    BytesRead:LongInt;
    Process:TProcess;
  begin
    Process:=MotorSpelare.Process;

    if Process.Running then
    begin
      BytesRead := 0;
      BytesAvailable := Process.Output.NumBytesAvailable;
      while BytesAvailable>0 do
      begin
        SetLength(Buffer, BytesAvailable);
        BytesRead := Process.OutPut.Read(Buffer[1], BytesAvailable);
        MotorSpelare.Parse(copy(Buffer,1, BytesRead));
        BytesAvailable := Process.Output.NumBytesAvailable;
        NoMoreOutput := false;
      end;
    end else
    	ShowMessage('Processen körs inte! (DoStuffForProcess)');
  end;
begin
  repeat
    NoMoreOutput := true;
    DoStuffForProcess(Self);
  until noMoreOutput;
end;



end.

