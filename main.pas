unit Main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, datatypes,
  StdCtrls, ExtCtrls, ComCtrls, process, kommunikation,
  Spin, Clipbrd,LCLtype, Globals, Spelregler,
  Nytt_Parti;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    CheckBox1: TCheckBox;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Memo1: TMemo;
    Memo2: TMemo;
    Memo3: TMemo;
    Panel1: TPanel;
    SpinEdit1: TSpinEdit;
    SpinEdit2: TSpinEdit;
    procedure Button1Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure CheckBox1Change(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure SpinEdit2Change(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

		TDummyClass = class
		public
		procedure ClickImage(Sender: TObject);
		end;
		var
                Dummy: TDummyClass = nil; //för att få procedurerna till metoder

var
  Form1: TForm1;
  Bilder: array[0..7,0..7] of TImage;
  Selected:integer=-1;


const
  BIGRADIE=0.8;
  MEDRADIE=0.6;
  SMARADIE=0.4;

  RADIER: array[0..SIZES-1] of real=(SMARADIE,MEDRADIE,BIGRADIE);

  BAKGRUNDSFARG=ClOlive;
  SELECTEDFARG=ClRed;
  DRAGFARG=ClAqua;
  INGENRUTA=clBlue;

  ClOrange=$00A5FF;
FARGER: array [0..3] of TColor=(clyellow,clorange,cllime,clpurple);


//function readuntillspaceorend(s:string):string;

procedure redrawimage(x,y:integer);
procedure redrawall;
Procedure resetparti;

implementation

{
function readuntillspaceorend(s:string):string;
var ats:integer=1;
begin
result:='';
while (length(s)>=ats) and (s[ats]<>' ') do begin
      result+=s[ats];
      inc(ats)
      end;
end;
}


Procedure resetparti;
begin
Parti.Drag:=0;
end;

procedure TDummyClass.ClickImage(Sender: TObject);
var
tagx,tagy:integer;
sq:TKoordinat;
fromsq:TKoordinat;
Ruta:TSquare;
begin
tagx:=TImage(sender).Tag mod 8;
tagy:=TImage(sender).Tag div 8;
Ruta:=Parti.State.Board[tagx, tagy];
    if TImage(sender).Tag=Selected then begin //Ifall klicka på selekterad
       selected:=-1; //Avselektering
       redrawall;
    end else

    if (selected<0) then begin //Ifall inte selekterad
       if (Ruta.antal<>0) and (Ruta.peices[Ruta.antal-1].player=Globals.SpelareSomForFlytta) then
          selected:=TImage(sender).tag;
       redrawall;
    end else

    if (TImage(sender).Tag<>Selected) and (selected>=0) then begin
       sq.x:=tagx;
       sq.y:=tagy;
       fromsq.x:=Selected mod 8;
       fromsq.y:=Selected div 8;
       if Parti.State.Board[selected mod 8, selected div 8].peices[Parti.State.Board[selected mod 8, selected div 8].antal-1].canmoveto(sq,Parti.State.Board) then begin
          //Ifall kan flytta dit
          GUI_Drag.nullmove:=false;
          GUI_Drag.from:=fromsq;
          GUI_Drag.moveto:=sq;
          selected:=-1;
	  end
          else if (Parti.State.Board[tagx, tagy].antal>0)
and (Parti.State.Board[tagx, tagy].peices[Parti.State.Board[tagx, tagy].antal-1].color = Parti.State.Board[selected mod 8, selected div 8].peices[Parti.State.Board[selected mod 8, selected div 8].antal-1].color) then begin
          //Annan markerbar docka
          selected:=TImage(sender).tag;
          end;
       redrawall;
    end;
end;

procedure redrawall;
var
forer:integer;
begin
  for forer:=0 to 63 do
    redrawimage(forer mod 8, forer div 8);
  Application.ProcessMessages;
end;

procedure redrawimage(x,y:integer);
var
tempkoordinat:Tkoordinat;
selkoordinat:Tkoordinat;

forer:integer;
begin
     Bilder[x,y].Left:=(x)*Form1.Panel1.Width div 8;
     Bilder[x,y].Top:=(7-y)*Form1.Panel1.Height div 8;
     Bilder[x,y].Width:=Form1.Panel1.Width div 8;
     Bilder[x,y].Height:=Form1.Panel1.Height div 8;
     Bilder[x,y].Refresh;
     Bilder[x,y].Update;
     Bilder[x,y].Repaint;

     //Rita rutans bakgrund
     Bilder[x,y].Canvas.Brush.Color:=BAKGRUNDSFARG;
     if (Bilder[x,y].Tag=selected) and (Parti.State.Board[x,y].antal>0) then
        Bilder[x,y].Canvas.Brush.Color:=SELECTEDFARG;

     tempkoordinat.x:=x;
     tempkoordinat.y:=y;
     if is_in(tempkoordinat,OEXISTERANDERUTOR,ANTALOEXISTERANDERUTOR) then
     	Bilder[x,y].Canvas.Brush.Color:=INGENRUTA;

     selkoordinat.x:=selected mod 8;
     selkoordinat.y:=selected div 8;
     if (selected<>-1) and (Parti.State.Board[selkoordinat.x,selkoordinat.y].antal>0) and (Parti.State.Board[selkoordinat.x,selkoordinat.y].peices[Parti.State.Board[selkoordinat.x,selkoordinat.y].antal-1].canmoveto(tempkoordinat,Parti.State.board)) then
     	Bilder[x,y].Canvas.Brush.Color:=DRAGFARG;

     Bilder[x,y].Canvas.Rectangle(0,0,Bilder[x,y].Canvas.Width,Bilder[x,y].Canvas.Height);

     //Rita pjäser
     for forer:=Parti.State.Board[x,y].antal-1 downto 0 do
     if (forer=(Parti.State.Board[x,y].antal-1)) or form1.CheckBox1.Checked  then begin
        Bilder[x,y].Canvas.Brush.Color:=FARGER[Parti.State.Board[x,y].peices[forer].color];
        Bilder[x,y].Canvas.EllipseC(Form1.Panel1.Width div 16,Form1.Panel1.Height div 16,
     				    Round(RADIER[Parti.State.Board[x,y].peices[forer].size]*Form1.Panel1.Width/16),
                                    Round(RADIER[Parti.State.Board[x,y].peices[forer].size]*Form1.Panel1.Height/16));
        end;



end;
{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
var
forer:integer;
begin

for forer:=0 to 63 do begin
  Bilder[forer mod 8,forer div 8]:=TImage.Create(Panel1);
  Bilder[forer mod 8,forer div 8].Tag:=forer;
  Bilder[forer mod 8,forer div 8].Parent:=Panel1;
  Bilder[forer mod 8,forer div 8].OnClick:=@Dummy.clickimage;
end;


for forer:=0 to DOLLS-1 do
    parti.State.peices[forer]:=TDoll.Create;


resetgame(parti.State);

redrawall;

                       {
      Parti.Spelare[0].VName:=Label1;
      Parti.Spelare[0].VAuthor:=Label2;

      Parti.Spelare[0].VBest:=Label10;

      Parti.Spelare[0].VNodes:=Label3;
      Parti.Spelare[0].VScore:=Label4;
      Parti.Spelare[0].VPv:=Label5;
      Parti.Spelare[0].VNPS:=Label6;
      Parti.Spelare[0].VDepth:=Label7;
      Parti.Spelare[0].VCurrMove:=Label8;
      Parti.Spelare[0].VCurrMoveNumber:=Label9;

      Parti.Spelare[0].VMultiPv:=Memo1;

      Parti.Spelare[0].VAlloutput:=nil;
      Parti.Spelare[0].VAllunprocessed:=nil;
                       }
Parti.State.turn:=0;

end;

procedure TForm1.CheckBox1Change(Sender: TObject);
begin
  redrawall;
end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  Avsluta_omedelbart:=true;
end;


procedure TForm1.Button5Click(Sender: TObject);
begin
  ClipBoard.AsText:=Babupos(Parti.State);
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  Form3.Show;
end;

procedure TForm1.Button6Click(Sender: TObject);
begin
//showmessage(Clipboard.AsText);
  if Babupostostate(Clipboard.AsText,Parti.State)<>0 then
     showmessage('Ogiltig ställning');
end;

procedure TForm1.Button7Click(Sender: TObject);
begin
  Babupostostate('0d10e11d11e12d12e10a50a41a51a42a52a40e80d81e81d82e82d80h40h51h41h52h42h51',Parti.State);
end;

procedure TForm1.Button8Click(Sender: TObject);
begin
  Babupostostate('0d10e11d11e12d12e10h40h51h51h42h52h40e80d81e81d82e82d80a50a41a51a42a52a41',Parti.State);
end;


procedure TForm1.FormDestroy(Sender: TObject);
var forer:integer;
begin
{
for forer:=0 to 63 do
    Bilder[forer div 8,forer mod 8].destroy;
}
end;

procedure TForm1.SpinEdit2Change(Sender: TObject);
begin
  Panel1.Width:=spinedit2.Value;
  Panel1.Height:=spinedit2.Value;
end;


initialization
  {$I main.lrs}

end.

