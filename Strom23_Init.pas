unit Strom23_Init;

// V tomto subore sa nachadza funkcia InitTree, ktora vrati pointer na prazdny strom (nil)

interface

uses Strom23_Typy;

function InitTree:pVrchol;

implementation

function InitTree:pVrchol;
begin
    InitTree := nil;
end;

end.