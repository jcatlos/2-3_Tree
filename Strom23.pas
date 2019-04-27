unit Strom23;

interface

uses Strom23_Typy, Strom23_Vypis, Strom23_Insert, Strom23_Init, Strom23_Delete;

procedure VypisStrom(koren: pVrchol);
procedure Delete(var koren: pVrchol; hodnota: longint);
procedure Insert(var koren: pVrchol; hodnota: longint);  
function InitTree:pVrchol;

type
    pVrchol = Strom23_Typy.pVrchol;
    pPrvok = Strom23_Typy.pPrvok;

    Vrchol = Strom23_Typy.Vrchol;
    Prvok = Strom23_Typy.Prvok;


implementation

procedure VypisStrom(koren: pVrchol); 
begin
    Strom23_Vypis.VypisStrom(koren);
end;

procedure Delete(var koren: pVrchol; hodnota: longint);
begin
    Strom23_Delete.Delete(koren, hodnota);
end;

procedure Insert(var koren: pVrchol; hodnota: longint);
begin
    Strom23_Insert.Insert(koren, hodnota);
end;  

function InitTree: pVrchol;
begin
    InitTree := Strom23_Init.InitTree;
end;

end.
