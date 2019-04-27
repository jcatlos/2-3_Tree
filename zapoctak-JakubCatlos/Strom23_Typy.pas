unit Strom23_Typy;

{ // V tomto subore sa nachadzaju datove struktury vyuzite na vytvorenie stromu }

interface

type
    pVrchol = ^Vrchol;
    pPrvok = ^Prvok;

    Vrchol = record
        Rodic: pVrchol;                     { // Rodic   = Pointer na rodica vrcholu }
        Prvky: array [1..2] of pPrvok;      { // Prvky   = Pointery na pozicie vo vrchole }
        Syn: pVrchol;                       {  // Syn     = Pointer na vrchol, v ktorom su hodnoty mensie ako hodnota prveho prvku }
    end;

    Prvok = record
        Hodnota: longint;                   { // Hodnota = Hodnota, ktoru prvok reprezentuje }
        Pocet: longint;                     { // Pocet   = Kolkokrat sa prvok nachadza v strome }
        Syn: pVrchol;                       { // Syn     = Pointer na vrchol, v ktorom su hodnoty vacsie ako "Hodnota"  }
    end;                                    { //           (Narozdiel od vrcholu, kde "Syn" odkazuje na mensie hodnoty) }
    
    { // Zdruzenie prvku a jeho 'syna' umoznuje jednoduchsi presun prvkov s korespondujucou podvetvou }

function PrazdnyPrvok: pPrvok;
function VytvorPrvok(hodnota: longint; syn: pVrchol): pPrvok;
function VytvorVrchol(prvok: pPrvok; syn: pVrchol): pVrchol;
procedure VymenPrvky(var prvok1, prvok2: pPrvok);
function PozriDuplicitu(vrchol:pVrchol; hodnota:longint):boolean;

implementation

(*-------------------------------* PRAZDNY PRVOK *-------------------------------*)
{ Vrati prazdny prvok - Prvok s hodnotou -1, ktoreho syn je nil }
{ (Obcas potrebujeme na nejake miesto v strome vlozit prazdny prvok do vrcholu) }
{ Vstup: Ziadny }

function PrazdnyPrvok: pPrvok;
begin
    new(PrazdnyPrvok);
    PrazdnyPrvok^.Hodnota := -1;
    PrazdnyPrvok^.Pocet := 0;
    PrazdnyPrvok^.Syn := nil;
end;

(*-------------------------------* VYTVOR PRVOK *-------------------------------*)
{ Vytvori  prvok so zadanou hodnotou a synom }
{ Vstup: Prvok, ktory ma obsahovat; Pointer na jeho rodica; Pointer na jeho syna } 

function VytvorPrvok(hodnota: longint; syn: pVrchol): pPrvok;
begin
    new(VytvorPrvok);
    VytvorPrvok^.Hodnota := hodnota;
    VytvorPrvok^.Syn := syn;
    PrazdnyPrvok^.Pocet := 1;
end;

// KED PRIDAVAM PRVOK - ZMENIT HODNOTU

(*-------------------------------* VYTVOR VRCHOL *-------------------------------*)
{ Vytvori vrchol obsahujuci 1 prvok zatial bez rodica a vrati nanho adresu }
{ -> Rodica mu potom musime doplnit!!! }
{ Vstup: Prvok, ktory ma obsahovat; Pointer na jeho rodica; Pointer na jeho syna } 

function VytvorVrchol(prvok: pPrvok; syn: pVrchol): pVrchol;
var Vrchol: pVrchol;
begin
    new(Vrchol);                
    Vrchol^.Rodic := nil;                           
    Vrchol^.Syn := syn;
    Vrchol^.Prvky[1] := prvok;
    Vrchol^.Prvky[2] := PrazdnyPrvok;
    if prvok^.Syn <> nil then prvok^.Syn^.Rodic := vrchol;      { Ak ma vkladany prvok syna, tak synovi nastavime ako rodica tento vrchol }
    if syn <> nil then syn^.Rodic := vrchol;                    { Ak davam normalneho syna, synovi rovno nastavim vrchol ako rodica}
    VytvorVrchol := Vrchol;
end;

(*-------------------------------* VYMEN PRVKY *-------------------------------*)
{ Vymeni dva zadane prvky }
    { Vstup: 2 Pointery na prvky, ktore chceme vymenit }

procedure VymenPrvky(var prvok1, prvok2: pPrvok);
var tmpPrvok: pPrvok;
begin
    tmpPrvok := prvok1;
    prvok1 := prvok2;
    prvok2 := tmpPrvok;
end;

(*-------------------------------* POZRI DUPLICITU *-------------------------------*)
{ Pozrie, ci sa hodnota nachadza v danom vrchole. Ak sa tam nachadza, zvysi prislusnu pocetnost. }
    { Vstup: vrchol a hladana hodnota }
    { Vystup: boolean, ci sa hodnota nachadza vo vrchole }

function PozriDuplicitu(vrchol:pVrchol; hodnota:longint):boolean;
begin
    if (hodnota = vrchol^.Prvky[1]^.Hodnota) then 
    begin
        vrchol^.Prvky[1]^.Pocet := vrchol^.Prvky[1]^.Pocet +1;
        PozriDuplicitu := true;
    end
    else if (hodnota = vrchol^.Prvky[2]^.Hodnota) then 
    begin
        vrchol^.Prvky[2]^.Pocet := vrchol^.Prvky[2]^.Pocet +1;
        PozriDuplicitu := true;
    end
    else PozriDuplicitu := false;
end;

end.