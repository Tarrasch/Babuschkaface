unit Spela_Parti;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Globals, Spelregler, Dialogs, Clipbrd;

Procedure SpelaParti;

const SPELARNAS_FARGNAMN:array[0..3] of string=('Gul','Orange','Grön','Lila');
implementation
uses Main;


Procedure SpelaParti;
var
Move:TMove;
begin
     Parti.Drag:=0;
     Form1.Label13.Visible:=true;
     while not Is_Finished(Parti.State) and not Avsluta_omedelbart do begin
           Form1.Label13.Caption:=SPELARNAS_FARGNAMN[parti.State.turn mod 4]+'s tur';
           //ClipBoard.AsText:=Babupos(Parti.State);
           Move:=parti.Spelare[parti.State.turn mod 4].get_move;
           if Avsluta_omedelbart then
              break;
           Make_Move(Parti.State, Move);
           //Parti.Protkoll[Parti.Drag]:=Move;
           inc(Parti.Drag);
           redrawall;
     end;
     Beep;
     ShowMessage('Partiet klart.');
     Form1.Label13.Visible:=false;
end;

end.

