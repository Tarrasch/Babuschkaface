unit ManniskoSpelare;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Spelare, Spelregler, Globals, Forms;

type
  TManniskoSpelare= Class(TSpelare)
  private

  Public
      Function Get_move:TMove; override;
  end;

implementation
uses
main;

Function TManniskospelare.Get_move:TMove;
begin
if Is_Null_Turn(Parti.State) then
   exit(NullMove);

SpelareSomForFlytta:=Globals.Parti.Drag mod 4;
Globals.GUI_Drag:=UndefinedMove;

while (GUI_Drag=UndefinedMove) and not Avsluta_omedelbart do begin
      Sleep(50);
      Application.ProcessMessages;
      end;

result:= GUI_Drag;
SpelareSomForFlytta:=-1;
Selected:=-1;
redrawall;
end;

end.

