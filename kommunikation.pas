unit kommunikation;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, Buttons,
  StdCtrls, ExtCtrls, Process, LCLProc, ComCtrls, datatypes, Globals;


procedure AvbrytProcess(Process:TProcess);
procedure Avbryt_o_nil_process(var Process:TProcess);
procedure SkickaData(Process:TProcess;rad:string);
procedure StartaProcess(var Process:TProcess;const CommandLine: string);
//procedure ReadOutput;

implementation

uses Main, motorspelare;

procedure Avbryt_o_nil_process(var Process:TProcess);
begin
  AvbrytProcess(Process);
  Process.Free;
  Process:=nil;
end;

procedure AvbrytProcess(Process:TProcess);
begin
  if Process <> nil then
    if Process.Running then
      Process.Terminate(0);
end;

procedure SkickaData(Process:TProcess;rad:string);
begin
    if Process.Running then begin
      If process=nil then
      	 showmessage('Process=nil!');
      Process.Input.Write(rad[1], length(rad));
      process.input.write(lineending,length(lineending));
  end;
end;

procedure StartaProcess(var Process:TProcess;const CommandLine: string);
begin
  if Process = nil then
     Process:=TProcess.Create(nil);
  AvbrytProcess(Process);
  begin
    Process.CommandLine := CommandLine;
    Process.Options := [poUsePipes];
    Process.Execute;
  end;
end;
     {
procedure ReadOutput;
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
//      showmessage(inttostr(BytesAvailable));
      while BytesAvailable>0 do
      begin
        SetLength(Buffer, BytesAvailable);
        BytesRead := Process.OutPut.Read(Buffer[1], BytesAvailable);
        MotorSpelare.Parse(copy(Buffer,1, BytesRead));
        BytesAvailable := Process.Output.NumBytesAvailable;
        NoMoreOutput := false;
      end;
     // if BytesRead>0 then
       // OutputMemo.SelStart := Length(OutputMemo.Text);
    end;
  end;
begin
  repeat
    NoMoreOutput := true;
    for i:=0 to LystnandeProcesser.Count-1 do begin
        DoStuffForProcess(TMotorSpelare(LystnandeProcesser[i]));
        end;
    {
    DoStuffForProcess(Parti.Spelare[0]);
    DoStuffForProcess(Parti.Spelare[1]);
    DoStuffForProcess(Parti.Spelare[2]);
    DoStuffForProcess(Parti.Spelare[3]);
    }
    //måste ändras till att den läser från en lista
  until noMoreOutput;
end;
    }

end.

