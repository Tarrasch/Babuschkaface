unit Nytt_Parti;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Globals, ExtCtrls, Manniskospelare, Motorspelare, Spelregler,
  Spela_Parti;

type

  { TForm3 }

  TForm3 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    RadioGroup1: TRadioGroup;
    RadioGroup2: TRadioGroup;
    RadioGroup3: TRadioGroup;
    RadioGroup4: TRadioGroup;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

VSpelareInfo=record
       RBHuman,RBComp:TRadioButton;
end;
var
  Form3: TForm3;
  Knappar: Array[0..3] of TButton;

  GroupBoxes:Array[0..3] of TRadioGroup;


implementation

{ TForm3 }

procedure TForm3.FormCreate(Sender: TObject);
begin
  GroupBoxes[0]:=RadioGroup1;
  GroupBoxes[1]:=RadioGroup2;
  GroupBoxes[2]:=RadioGroup3;
  GroupBoxes[3]:=RadioGroup4;
end;

procedure TForm3.Button2Click(Sender: TObject);
var
i:integer;
begin //Starta 2-player-game
  for i := 0 to 3 do
      Parti.Spelare[i].Free;

  for i := 0 to 1 do begin
      if GroupBoxes[i].ItemIndex=0 then
      	 Parti.Spelare[i]:=TManniskospelare.Create
      else
          Parti.Spelare[i]:=TMotorSpelare.Create;
      end;

Parti.Spelare[2]:=Parti.Spelare[1];//så att spelare 2 blir spelare 3
Parti.Spelare[1]:=TManniskoSpelare.Create;
Parti.Spelare[3]:=TManniskoSpelare.Create;
Babupostostate('0d10e11d11e12d12e10h40h51h51h42h52h40e80d81e81d82e82d80a50a41a51a42a52a41',Parti.State);
Form3.Close;
SpelaParti;
Application.ProcessMessages;
end;

procedure TForm3.Button1Click(Sender: TObject);
var
i:integer;
begin //Starta 4-player-game
  for i := 0 to 3 do begin
      Parti.Spelare[i].Free;
      if GroupBoxes[i].ItemIndex=0 then
      	 Parti.Spelare[i]:=TManniskoSpelare.Create
      else
          Parti.Spelare[i]:=TMotorSpelare.Create;
      end;
Babupostostate('0d10e11d11e12d12e10a50a41a51a42a52a40e80d81e81d82e82d80h40h51h41h52h42h51',Parti.State);
Form3.Close;
SpelaParti;
Application.ProcessMessages;
end;

initialization
  {$I nytt_parti.lrs}

end.

