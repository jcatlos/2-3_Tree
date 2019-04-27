unit Strom23_Insert;

(* V tomto subore sa nachadza funkcia Insert so vsetkymi funkciami a datovymi strukturami, ktore potrebuje *)

interface

uses Strom23_Init, Strom23_Typy, Strom23_Vypis;

procedure Insert(var koren: pVrchol; hodnota: longint);  
{ Pouzivame referenciu na koren, pretoze B-Stromy rastu do vysky, takze koren sa moze zmenit }

implementation

(*-------------------------------* PRAZDNY PRVOK *-------------------------------*)
{ Vrati prazdny prvok - Prvok s hodnotou -1, ktoreho syn je nil }
{ (Obcas potrebujeme na nejake miesto v strome vlozit prazdny prvok do vrcholu) }
{ Vstup: Ziadny }

function PrazdnyPrvok: pPrvok;
begin
    new(PrazdnyPrvok);
    PrazdnyPrvok^.Hodnota := -1;
    PrazdnyPrvok^.Syn := nil;
    PrazdnyPrvok^.Pocet := 0;                                   { Prvok nema ziadnu hodnotu }
end;

(*-------------------------------* VYTVOR PRVOK *-------------------------------*)
{ Vytvori  prvok so zadanou hodnotou a synom }
{ Vstup: Prvok, ktory ma obsahovat; Pointer na jeho rodica; Pointer na jeho syna } 

function VytvorPrvok(hodnota: longint; syn: pVrchol): pPrvok;
begin
    new(VytvorPrvok);
    VytvorPrvok^.Hodnota := hodnota;
    VytvorPrvok^.Syn := syn;
    VytvorPrvok^.Pocet := 1;                                    { Prvok sme prave vytvorili, takze v strome je iba raz }
end;

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


(*-------------------------------* VYMEN PRVKY *-------------------------------*)
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



(*-------------------------------* INSERT *-------------------------------*)
{ Vlozi hodnotu do stromu }
{ Vstup: Pointer na koren stromu, do ktoreho chceme vkladat; Hodnota, ktoru chceme vlozit }
{ -> Hodnota moz byt iba kladne cislo, pretoze volne miesto oznacujeme -1 }

procedure Insert(var koren: pVrchol; hodnota: longint);
var 
    prvok: pPrvok; 
    vrchol: pVrchol;                        { Pointer na vrchol, v ktorom sa prave nachadzame }
begin
    if koren = nil then                     { Ak strom neexistuje, vytvori ho s danou hodnotou }
    begin
        prvok := VytvorPrvok(hodnota, nil); { Vytvorime prvok bez syna, kedze prvy vytvoreny vrchol je list }
        koren := VytvorVrchol(prvok, nil);  { Vytvorime novy koren stromu, ale je aj list takze nema syna }
                                            { Zatial obsahuje iba jednu hodnotu - druhy prvok bude teda prazdny }
    end
    else        
    begin                                   { Kedze strom existuje - je v nom aspon 1 prvok, musime: }
        vrchol := koren;
        { Nechceme mat v strome duplicitne prvky, takze v kazdom vrchole, ktorym prechadzame pozrieme, ci sa tam hodnota uz nenachadza }
        { -> Ak ano, zvysime jej pocetnost a skoncime }
        if (PozriDuplicitu(vrchol, hodnota)) then exit;
        while vrchol^.Syn <> nil do                         { 1.) Najst list, do ktoreho chceme pridat hodnotu }
        begin
            if (PozriDuplicitu(vrchol, hodnota)) then exit;
            if hodnota < vrchol^.Prvky[1]^.Hodnota                  { Ak je hodnota mensia ako 1. prvok, ideme do syna vrcholu }
                then vrchol := vrchol^.Syn                              { Vrchol nemoze byt prazdny, takze ma aspon 1 prvok }
            else if (vrchol^.Prvky[2]^.Hodnota <> -1)               { Ak 2. prvok existuje a hodnota je vacsia ako jeho hodnota, ideme do jeho syna }
                and (hodnota > vrchol^.Prvky[2]^.Hodnota)
                    then vrchol := vrchol^.Prvky[2]^.Syn
            else vrchol := vrchol^.Prvky[1]^.Syn;                   { Ak 2. prvok neexistuje, alebo [hodnota 1. prvku] <= hodnota <= [hodnota 2. prvku] }
        end;
                                                            { 2.) Vlozit hodnotu na spravne miesto v liste }
                                                                { Sme v liste, takze nemusime riesit potomkov, lebo ziadni neexistuju }
        if (PozriDuplicitu(vrchol, hodnota)) then exit;
        if vrchol^.Prvky[2]^.Hodnota = -1 then                  { Ak je v liste volne miesto, tak tam proste pridame prvok s nasou hodnotou }
        begin
            prvok := VytvorPrvok(hodnota, nil);                     { Vytvorime prvok }
            if hodnota > vrchol^.Prvky[1]^.Hodnota then             { Ak je hodnota vacsia ako hodnota ulozeneho prvku, prvok ulozime na 2. miesto }
                vrchol^.Prvky[2] := prvok
            else                                                    { Inak: }
            begin
                vrchol^.Prvky[2] := vrchol^.Prvky[1];                   { 1. prvok posunieme}
                vrchol^.Prvky[1] := prvok;                              { Na prve miesto dame vytvoreny prvok }
            end;
            prvok := nil;                                           { Uz nemame prvok na umiesnovanie }
        end
        else                                                    { Ak v liste nie je volne miesto, musime stiepit }
        begin 
            prvok := VytvorPrvok(hodnota, nil);                 { V nasledujucej podmienke prvok umiestnime na adekvatne miesto a do prvku ulozime prostredny prvok }
                                                                { Nemusime kontrolovat existenciu prvku, kedze list je plny }           
            if hodnota < vrchol^.Prvky[1]^.Hodnota          
                then VymenPrvky(prvok, vrchol^.Prvky[1])
            else if (vrchol^.Prvky[2]^.Hodnota <> -1) and (hodnota > vrchol^.Prvky[2]^.Hodnota)
                then VymenPrvky(prvok, vrchol^.Prvky[2]);           { Inak je hodnota prostredna, takze nic nemusime menit }
                                                            { 3.) Ulozit prostredny prvok vyssie }
            prvok^.Syn := VytvorVrchol(vrchol^.Prvky[2], nil);          { Vytvorime vrchol obsahujuci najvacsi prvok z listu (sme v liste - nema syna) }
            vrchol^.Prvky[2] := PrazdnyPrvok;                           { Najvacsi prvok z listu sme premiestnili do noveho vrcholu, z tohoto ho musime zmazat }
            if vrchol^.Rodic <> nil then vrchol := vrchol^.Rodic        { Ak nie sme aj v koreni, presunieme sa na rodica }
            else    { Specialny pripad, ked strom ma iba 1 vrstvu }
            begin
                koren := VytvorVrchol(prvok, vrchol);               { Vytvarame novy koren, takze jeho rodic je nil z definicie }
                prvok := nil;                              
            end;

            { Ked rodic je nil, tak sme v koreni, ked prvok = nil, tak sme prvok zaradili do volneho vrcholu }
            { Vacsina kodu je rovnaka ako v pripade s listami, akurat uz riesime aj potomkov, takze komentovat budem iba pripadne rozdiely }
            while (vrchol^.Rodic <> nil) and (prvok <> nil) do
            begin
                if vrchol^.Prvky[2]^.Hodnota = -1 then              
                begin
                    if prvok^.Hodnota > vrchol^.Prvky[1]^.Hodnota
                        then vrchol^.Prvky[2] := prvok                                    
                    else begin
                        vrchol^.Prvky[2] := vrchol^.Prvky[1];
                        vrchol^.Prvky[1] := prvok 
                    end;
                    prvok^.Syn^.Rodic := vrchol;                    { Syn prvku zatial nema ulozeneho rodica, lebo sme nevedeli, kde prvok skonci - teraz to vieme, takze ho musime prepisat }
                    prvok := nil;
                end
                else                                                { Stiepenie vrcholu }
                begin
                    hodnota := prvok^.Hodnota;                      
                    if hodnota < vrchol^.Prvky[1]^.Hodnota then         
                        begin 
                            VymenPrvky(prvok, vrchol^.Prvky[1]);
                            prvok^.Syn^.Rodic := vrchol;                
                        end
                    else if hodnota > vrchol^.Prvky[2]^.Hodnota then    
                        begin 
                            VymenPrvky(prvok, vrchol^.Prvky[2]);
                            prvok^.Syn^.Rodic := vrchol;                       
                        end;                                        
                    prvok^.Syn := VytvorVrchol(vrchol^.Prvky[2], prvok^.Syn);  
                    vrchol^.Prvky[2] := PrazdnyPrvok;                   
                end;
                vrchol := vrchol^.Rodic;                            
            end;                                        
            { Teraz sme bud prvok umiestnili alebo sme v koreni }
            { -> Ak sme v koreni, vyberieme prostredny prvok a vytvorime novy koren s tymto vrcholom }
            if prvok <> nil then                
            begin
                if vrchol^.Prvky[2]^.Hodnota = -1 then              
                begin
                    if prvok^.Hodnota > vrchol^.Prvky[1]^.Hodnota
                        then vrchol^.Prvky[2] := prvok                                    
                    else begin
                        vrchol^.Prvky[2] := vrchol^.Prvky[1];
                        vrchol^.Prvky[1] := prvok 
                    end;
                    prvok^.Syn^.Rodic := vrchol;                       
                    prvok := nil;
                end
                else                                                { Stiepenie korena }
                begin  
                    hodnota := prvok^.Hodnota;                      
                    if hodnota < vrchol^.Prvky[1]^.Hodnota then         
                        begin 
                            VymenPrvky(prvok, vrchol^.Prvky[1]);
                            prvok^.Syn^.Rodic := vrchol;                
                        end
                    else if hodnota > vrchol^.Prvky[2]^.Hodnota then    
                        begin 
                            VymenPrvky(prvok, vrchol^.Prvky[2]);
                            prvok^.Syn^.Rodic := vrchol;                       
                        end;                                        
                    
                    prvok^.Syn := VytvorVrchol(vrchol^.Prvky[2], prvok^.Syn);
                    prvok^.Syn^.Rodic := vrchol;
                    vrchol^.Prvky[2] := PrazdnyPrvok;     
                    koren := VytvorVrchol(prvok, vrchol);               { // Vytvorili sme novy koren, ktoreho syn je predchadzajuci koren a jeho jediny prvok je nas neumiestneny prvok }
                    prvok := nil;
                end;
            end;


        end;
    end;
end;

end.