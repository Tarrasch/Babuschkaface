unit Globals;

Interface

uses datatypes, Classes, Spelregler, Parti_Unit, Spelare;


var
  Parti: TParti;
  //Paused: Boolean=true;
  //LystnandeProcesser:TList;
  SpelareSomForFlytta:Integer=-1;
  GUI_Drag:TMove;
  Spelet_pagar:boolean=false;
  Motorpath:string ='Babumotor.exe';
  Avsluta_omedelbart:boolean=false;





implementation
var
i:integer;

initialization
begin
     Parti:=TParti.Create;
//     LystnandeProcesser:=TList.Create;
end;

finalization
begin
{
     for i:=0 to LystnandeProcesser.Count-1 do begin
        TSpelare(LystnandeProcesser[i]).Free;
        end;
     LystnandeProcesser.Free;}
end;

end.

