unit Spelare;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Spelregler, Dialogs, StdCtrls;

type

  TSpelare= Class
private
       FNamn:string;
       FVNamn:TCustomLabel;
  //   function get_Tid: integer;
       procedure SetNamn(s: string);
       procedure SetVNamn(CL: TCustomLabel);

Public
//    property Tid:integer read get_Tid; //i millisekunder
      property Namn: string read FNamn write SetNamn;
      property VNamn:TCustomLabel read FVNamn write SetVNamn;
      function get_move:TMove; virtual; abstract;
      //Procedure Free;


      //Procedurer
      //Procedure MakeBestMove;

      Constructor Create;
      //Destructor Destroy; virtual; abstract;
end;







implementation

uses main, kommunikation;

{
procedure TSpelare.Free;
begin
     if self<>nil then
     	self.Destroy;
end;
}
procedure TSpelare.SetVNamn(CL: TCustomLabel);
begin
     FVNamn:=CL;
     if VNamn<>nil then
     	VNamn.Caption:=Namn;
end;

procedure TSpelare.SetNamn(s: string);
begin
     FNamn:=s;
     if VNamn<>nil then
     	VNamn.Caption:=Namn;
end;

           {
function TSpelare.get_namn:string;
begin
     result:=Namn;
end;

procedure TSpelare.set_namn(s: string);
begin
     Namn:=s;
end;
       }

Constructor TSpelare.Create;
begin
           VNamn:=nil;

end;
             {
Procedure TSpelare.MakeBestMove;
begin

if not self.Bestmove.nullmove then begin
   if (Parti.State.Board[self.Bestmove.from.x,self.Bestmove.from.y].antal>0)
   then begin
       (Parti.State.Board[self.Bestmove.from.x,self.Bestmove.from.y].peices[Parti.State.Board[self.Bestmove.from.x,self.Bestmove.from.y].antal-1].moveto(self.Bestmove.moveto,Parti.State.board));
       inc(Parti.State.turn);
       end
   else
       showmessage('illegal drag i BestMove');
   end
else
    inc(Parti.State.turn);


end;
}



end.

