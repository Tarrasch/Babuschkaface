unit Parti_Unit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SpelRegler, Spelare;

type
TParti = class
  Private

  Public
      State:TGamestate;
      Spelare:array[0..3] of TSpelare;
      Protkoll:TMovelist;
      Drag:integer;
      //NyttParti:
end;


implementation
uses
Globals;

end.

