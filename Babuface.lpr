program Babuface;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms
  { you can add units after this }, Main, Spelregler,
kommunikation, datatypes, Spelare, Motorspelare, Globals,
Manniskospelare, Nytt_Parti, Spela_Parti, Parti_Unit;

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm3, Form3);
  Application.Run;
end.

