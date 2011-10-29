unit SpelRegler;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,Dialogs, math;

const
SIZES=3;
DOLLS=4*SIZES*2;

type
TKoordinat=record
     x:ShortInt;
     y:ShortInt;
end;

TMove=record
     nullmove:boolean;
     from:TKoordinat;
     moveto:TKoordinat;
end;


TMovelist=array[0..16*12] of TMove;


//RUTA
TDoll = class;

TPeaicesonsquare= array[0..SIZES-1] of TDoll;

TSquare=record
       antal: byte;
       peices: TPeaicesonsquare;
end;


//BRÄDET
 TBoard= array[0..7,0..7] of TSquare;


//DOCKA
TDoll=class
private
       index: integer; //0..23,  CSN, C=color(4),S=size(SIZES),N=number(2)
       pos  : TKoordinat;
       function legaltomoveto(ruta:TKoordinat;var board:TBoard):boolean;
public
      function moveto(ruta:TKoordinat;var board:TBoard): boolean;
      procedure addmoves(var list: TMovelist;var board:TBoard;var n:integer);
      function size:integer;
      function color:integer;
      function player:integer;
      function canmoveto(ruta:TKoordinat;var board:TBoard): boolean;
end;

TGamestate= record
            Board:TBoard;
            peices: array[0..DOLLS-1] of TDoll;
            turn:integer;// 0..oändlighet, turn mod 4 = den som är vid draget
end;

const
UndefinedMove:TMove=(nullmove:false; From:(x:0;y:0);moveto:(x:0;y:0));
NullMove:TMove=(nullmove:true; From:(x:0;y:0);moveto:(x:0;y:0));


procedure addallmoves(state:TGamestate;var movelist:TMovelist;var n:integer);
procedure resetgame(var state:TGamestate);


function convertsquareback(const square:TKoordinat;player:integer) :TKoordinat;
function convertsquare(const square:TKoordinat;player:integer) :TKoordinat;
function squareaheadof(const sq,sq0:TKoordinat;player:integer):boolean;
function is_in(const square:TKoordinat;var list:array of TKoordinat;n:integer):boolean;
function legaltojumpthrough(ruta:TKoordinat;size:integer;var board:TBoard):boolean;
procedure searchjumps(const atsquare,startsquare:TKoordinat;var list:array of TKoordinat;
	  		    var board:TBoard;var n:integer;const size:integer);
function Is_Null_Turn(var gs:TGamestate):boolean;
function Is_Finished(var gs:TGamestate):boolean;
function Player_Finished(var gs:TGamestate;const side:integer):boolean;
procedure Make_Move(var gs:TGamestate; m: TMove);


function Babupos(var State:TGamestate): string; //del av kommunikationen
function Babupostostate(pos: string; var State:TGamestate):integer; //del av kommunikationen

operator = (m1,m2:TMove) m:boolean;

const

     ANTALILLEGALARUTOR=12;
     ILLEGALARUTOR: array [0..ANTALILLEGALARUTOR-1] of TKoordinat=

     //Illegala rutor från spelare 1's perspektiv

     (
     (X:0;Y:3),
     (X:0;Y:4),
     (X:7;Y:3),
     (X:7;Y:4), //Rutorna där sidospelarna morphar/går i mål

     (X:0;Y:7),
     (X:0;Y:6),
     (X:1;Y:7),

     (X:7;Y:7),
     (X:7;Y:6),
     (X:6;Y:7), //Rutor som egentligen inte finns utridade på ett babucschka-bräde.

     (X:2;Y:7),
     (X:5;Y:7) //Rutorna som ligger t.h/t.v om mål



     //Eftersom de främre oritade rutorna är omöjliga att nå (för spelare 1) så tas de inte med
     );


     ANTALOEXISTERANDERUTOR=12;
     OEXISTERANDERUTOR: array [0..ANTALOEXISTERANDERUTOR-1] of TKoordinat=

     //Illegala rutor från alla spelares perspektiv (i.o.m. symmetrin)

     (

     (X:0;Y:7),
     (X:0;Y:6),
     (X:1;Y:7),

     (X:7;Y:7),
     (X:7;Y:6),
     (X:6;Y:7),

     (X:0;Y:0),
     (X:0;Y:1),
     (X:1;Y:0),

     (X:7;Y:0),
     (X:7;Y:1),
     (X:6;Y:0)

     );


implementation



operator = (m1,m2:TMove) m:boolean;
begin
   result:=((m1.nullmove=m2.nullmove) and (m1.nullmove=true)) or ((m1.from.x=m2.from.x) and (m1.moveto.x=m2.moveto.x) and (m1.from.y=m2.from.y) and (m1.moveto.y=m2.moveto.y) and (m1.nullmove=m2.nullmove));
end;


function convertsquareback(const square:TKoordinat;player:integer) :TKoordinat;
begin
    result:=convertsquare(square,(4-player) mod 4);
end;

procedure addallmoves(state:TGamestate;var movelist:TMovelist;var n:integer);
var forer:integer;
begin
for forer:=0 to 2*SIZES-1 do
    state.peices[forer+(state.turn mod 4)*SIZES*2].addmoves(movelist,state.Board,n);


end;

procedure resetgame(var state:TGamestate);
var forer:integer;
    tempkoord:TKoordinat;
begin

state.turn:=0;
for forer:=0 to 63 do
    state.Board[forer div 8,forer mod 8].antal:=0;

for forer:=0 to DOLLS-1 do begin
    state.peices[forer].index:=forer;

    tempkoord.y:=0;
    tempkoord.x:=3+forer mod 2; //växlar mellan mittenrutorna
    tempkoord:=convertsquare(tempkoord,state.peices[forer].color);

    state.peices[forer].pos:=tempkoord;
    state.Board[tempkoord.x,tempkoord.y].antal:=3;
    state.Board[tempkoord.x,tempkoord.y].peices[state.peices[forer].size]:=state.peices[forer];
end;


end;

function convertsquare(const square:TKoordinat;player:integer) :TKoordinat;
begin
    case player of
    0:begin result.x:=square.x;result.y:=square.y end;
    1:begin result.x:=square.y;result.y:=7-square.x end;
    2:begin result.x:=7-square.x;result.y:=7-square.y end;
    3:begin result.x:=7-square.y;result.y:=square.x end;
    end;
end;

function squareaheadof(const sq,sq0:TKoordinat;player:integer):boolean;
begin
    case player of
    0:result:=sq.y>sq0.y;
    1:result:=sq.x>sq0.x;
    2:result:=sq.y<sq0.y;
    3:result:=sq.x<sq0.x;
    end;
end;

function is_in(const square:TKoordinat;var list:array of TKoordinat;n:integer):boolean;
var
forer:integer;
begin
for forer:=0 to n-1 do
    if (square.x=list[forer].x) and (square.y=list[forer].y)
    then begin
         result:=true;
         exit;
         end;
result:=false;

end;

function legaltojumpthrough(ruta:TKoordinat;size:integer;var board:TBoard):boolean;
begin
        if not(ruta.x in[0..7]) or not(ruta.y in[0..7])  then
         begin
         result:=false;
         exit;
         end;
        if (board[ruta.x,ruta.y].antal>0) and (size<=board[ruta.x,ruta.y].peices[board[ruta.x,ruta.y].antal-1].size)
  	//ditrutan har docka som är för stor
   	then
         begin
         result:=false;
         exit;
         end;

        if is_in(ruta,OEXISTERANDERUTOR,ANTALOEXISTERANDERUTOR) then
         begin
         result:=false;
         exit;
         end;

        result:=true;

end;

function TDoll.legaltomoveto(ruta:TKoordinat;var board:TBoard):boolean;
var
tempkoord:TKoordinat;
begin
        if not legaltojumpthrough(ruta,self.size,board)  then
         begin
         result:=false;   //Man kan aldrig flytta till en ruta man ej kan hoppa igenom
         exit;
        end;


        if not squareaheadof(ruta,self.pos,self.player)  then
         begin
         result:=false;
         exit;
        end;

        tempkoord:=convertsquareback(ruta,self.player);

        if is_in(tempkoord,ILLEGALARUTOR,ANTALILLEGALARUTOR) then
        begin
         result:=false;
         exit;
        end;

        if tempkoord.y=7 then begin //på sista raden (mål)
           if (board[ruta.x,ruta.y].antal=0) then
              if self.size<>0 then
                   begin
         	    result:=false; //Ifall den första anländande inte är en minsta storlek
              	    exit;
              	   end
                   else
           else
           if (self.color<>board[ruta.x,ruta.y].peices[board[ruta.x,ruta.y].antal-1].color) or ((self.size-1)<>board[ruta.x,ruta.y].peices[board[ruta.x,ruta.y].antal-1].size) then
                   begin
         	    result:=false; //Ifall det är en motståndarpjäs eller för liten/stor docka där
              	    exit;
              	   end;
   	end;


        result:=true;
end;

procedure searchjumps(const atsquare,startsquare:TKoordinat;var list:array of TKoordinat;
	  		    var board:TBoard;var n:integer;const size:integer);
var xf,yf:integer;
    tempsquare,tempsquare2:TKoordinat;
begin
if is_in(atsquare,list,n) then exit;



list[n]:=atsquare;
inc(n);

for xf:=-1 to 1 do begin
    for yf:=-1 to 1 do begin

         tempsquare.x:= atsquare.x+2*xf;
         tempsquare.y:= atsquare.y+2*yf;
         tempsquare2.x:= atsquare.x+xf;
         tempsquare2.y:= atsquare.y+yf;


        if ((xf=0) and (yf=0)) or not legaltojumpthrough(tempsquare,size,board) then
           continue;

        if Board[tempsquare2.x,tempsquare2.y].antal>0 then
         searchjumps(tempsquare,startsquare, list, board, n, size); //Ifall det finns en pjäs mellan

    end;
end;



end;


function TDoll.color:integer;
begin
result:=index div (2*SIZES);
end;

function TDoll.player:integer;
begin
result:=index div (2*SIZES);
end;


function TDoll.size:integer;
begin
result:=(index div 2) mod SIZES;
end;


procedure TDoll.addmoves(var list: TMovelist;var board:TBoard;var n:integer);
var
   plist:array[0..49] of TKoordinat;
   pn:integer=0;
   tempkord:TKoordinat;
   forer:integer;
begin
  //Man börjar med de 3 främre rutorna  (pulling)
  if self<>Board[self.pos.x,self.pos.y].peices[Board[self.pos.x,self.pos.y].antal-1] then
   exit;

   tempkord:=convertsquareback(self.pos,self.player);
   inc(tempkord.y);
   dec(tempkord.x);
   plist[pn]:=convertsquare(tempkord,self.player);
   inc(pn);
   inc(tempkord.x);
   plist[pn]:=convertsquare(tempkord,self.player);
   inc(pn);
   inc(tempkord.x);
   plist[pn]:=convertsquare(tempkord,self.player);
   inc(pn);

   searchjumps(self.pos,self.pos,plist,board,pn,self.size);

   for forer:=0 to pn-1 do
       if self.legaltomoveto(plist[forer],board) then
          begin
               list[n].from:=self.pos;
               list[n].moveto:=plist[forer];
               inc(n);
          end;


end;


function TDoll.moveto(ruta:TKoordinat;var board:TBoard): boolean;
begin
if not self.canmoveto(ruta,board)
   then begin
        result:=false;
        showmessage('Illegalt drag gavs till motorn, från: (x=' +inttostr(self.pos.x)+', y=' +inttostr(self.pos.y)+ ') till :(x=' +inttostr(ruta.x)+', y=' +inttostr(ruta.y)+ ')');
        exit;
   end;

   board[ruta.x,ruta.y].peices[board[ruta.x,ruta.y].antal]:=self;
   inc(board[ruta.x,ruta.y].antal);

   dec(board[self.pos.x,self.pos.y].antal);
   self.pos:=ruta;

end;

function TDoll.canmoveto(ruta:TKoordinat;var board:TBoard): boolean;
var
   tlist:TMovelist;//har de nu för att se ifall illegala drag ges till motorn
   tn:integer=0;
   plist:array[0..20] of TKoordinat;
   forer:integer;
begin
self.addmoves(tlist,board,tn);

for forer:=0 to tn-1 do
    plist[forer]:=tlist[forer].moveto;


if is_in(ruta,plist,tn)
   then
        result:=true
   else
        result:=false;
end;


function Is_Null_Turn(var gs:TGamestate):boolean;
var
ml:TMovelist;
n:integer=0;
i:integer;
begin
for i := 6*(gs.turn mod 4) to 6*(gs.turn mod 4)+6-1 do begin;
    gs.peices[i].addmoves(ml,gs.Board,n);
    end;
result:=n=0;
end;

function Is_Finished(var gs:TGamestate):boolean;
var
i:integer;
spelare_finished:byte=0;
spelare_med_null_move:byte=0;
begin
for i:=0 to 3 do begin
    if Player_Finished(gs, i) then
       inc(spelare_finished);
    end;
if spelare_finished>=3 then
   exit(true);
for i:=1 to 4 do begin
    if Is_Null_Turn(gs) then
       inc(spelare_med_null_move);
    inc(gs.turn);
    end;
gs.turn-=4;
result:=spelare_med_null_move=4;
end;


function Player_Finished(var gs:TGamestate;const side:integer):boolean;
var
goal1:TKoordinat=(x:3;y:7);
goal2:TKoordinat=(x:4;y:7);
begin
goal1:=convertsquare(goal1, side);
goal2:=convertsquare(goal2, side);
result:=
(gs.Board[goal1.x,goal1.y].antal=3) and (gs.Board[goal1.x,goal1.y].peices[2].color=side) and
(gs.Board[goal2.x,goal2.y].antal=3) and (gs.Board[goal2.x,goal2.y].peices[2].color=side) ;
end;

procedure Make_Move(var gs:TGamestate; m: TMove);
var
ruta:TSquare;
begin
ruta:=gs.Board[m.from.x, m.from.y];
if m<>NullMove then
   ruta.peices[ruta.antal-1].moveto(m.moveto, gs.Board);
inc(gs.turn);
end;


function Babupos(var State:TGamestate): string;
{var
a,b:integer;
s:string[DOLLS*3+1+1];
begin
for a:=0 to DOLLS-1 do begin
    for b:=0 to State.Board[State.peices[a].pos.x,State.peices[a].pos.y].antal-1 do
    	if State.Board[State.peices[a].pos.x,State.peices[a].pos.y].peices[b]=State.peices[a] then
           s[a*3+1]:=char(b+ord('0'));
    s[a*3+2]:=char(State.peices[a].pos.y+ord('a'));
    s[a*3+3]:=char(State.peices[a].pos.x+ord('1'));
    end;
s[DOLLS*3+1]:=char(State.turn mod 4);
s[DOLLS*3+2]:=char(0); //"frivilligt" null-tecken

result:=s;

end;
}
var
a,b:integer;
s:string;
begin
s:='';
for a:=0 to DOLLS-1 do begin
    for b:=0 to State.Board[State.peices[a].pos.x,State.peices[a].pos.y].antal-1 do
    	if State.Board[State.peices[a].pos.x,State.peices[a].pos.y].peices[b]=State.peices[a] then
           s+=char(b+ord('0'));
    s+=char(State.peices[a].pos.x+ord('a'));
    s+=char(State.peices[a].pos.y+ord('1'));
    end;
s+=char(State.turn mod 4 +ord('1'));
s+=char(0); //"frivilligt" null-tecken

result:=s;

end;

function Babupostostate(pos: string; var State:TGamestate):integer; //del av kommunikationen
var
atpos:integer=1;
a,b,c:integer;
x,y,h:integer;
begin

if not (length(pos) in [DOLLS*3+1,DOLLS*3+2]) then
   exit(DOLLS*3+3);//=75

for a:=1 to DOLLS*3 do
    if
    ((((a-1) mod 3)=0) and  not (pos[a] in ['0'..'2'])) or
    ((((a-1) mod 3)=1) and  not (pos[a] in ['a'..'h'])) or
    ((((a-1) mod 3)=2) and  not (pos[a] in ['1'..'8'])) then
    exit(a);

if not (pos[DOLLS*3+1] in ['1'..'4']) then
   exit(DOLLS*3+1);


//Ställningen är troligen giltig nu

for a:=0 to 7 do
    for b:=0 to 7 do begin
        for c:=0 to 2 do
            State.Board[a,b].peices[c]:=nil;
        State.Board[a,b].antal:=0;
        end;

for a:=0 to DOLLS-1 do begin
    h:=ord(pos[a*3+1])-ord('0');
    x:=ord(pos[a*3+2])-ord('a');
    y:=ord(pos[a*3+3])-ord('1');
    State.peices[a].pos.x:=x;
    State.peices[a].pos.y:=y;


    State.Board[x,y].peices[h]:=State.peices[a];
    State.Board[x,y].antal:=max(State.Board[x,y].antal,h+1);
    end;
State.turn:=byte(pos[DOLLS*3+1])-byte('1');

exit(0); //lyckades
end;

end.
































