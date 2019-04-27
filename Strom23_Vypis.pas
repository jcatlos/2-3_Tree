unit Strom23_Vypis;

{ // V tomto subore sa nachadza funkcia VypisStrom so vsetkymi funkciami a datovymi strukturami, ktore potrebuje }

interface
uses Strom23_Typy;

procedure VypisStrom(koren: pVrchol);

implementation

(*-------------------------------* POUZITE TYPY *-------------------------------*)
{ // Vrcholy prechadzam za pomoci BFS, takze spracovavane vrcholy ukladam do fronty }

type 
    pFronta = ^Fronta;
    pVrcholSHlbkou = ^VrcholSHlbkou;

    VrcholSHlbkou = record          { // Ku kazdemu vrcholu si potrebujeme pamatat aj jeho hlbku, nech vieme, na ktoru uroven ho chceme vypisat }
        Vrchol: pVrchol;
        Hlbka: longint;
    end;

    Fronta = record
        Vrchol: pVrcholSHlbkou;     { // Adresa vrcholu vo fronte  } 
        Dalsi: pFronta;             { // Dalsi vrchol v poradi }
    end;

(*-------------------------------* VYHODENIE Z FRONTY *-------------------------------*)
{ // Vrati pointer na vrchol na zaciatku fronty
// Vstupna hodnota: Pointer na zaciatok (prvy prvok) a koniec (posledny prvok) fronty
    // Koniec potrebujeme, aby sme ho mohli prepisat v pripade vyhadzovania posledneho prvku z fronty }

function Vyhod(var zaciatok: pFronta): pVrcholSHlbkou; 
var pomocny: pFronta; tmp: pVrcholSHlbkou;                                { // Premenna sluziaca na docasne ulozenie adresy zaciatku fronty, kym nebude zmazany }
begin
    if zaciatok = nil then Vyhod := nil             { // Ak je fronta prazdna, vrati nil }
    else
    begin                                           { // Inak: }                             
        tmp := zaciatok^.Vrchol;
        //writeln('vyhadzujem ', tmp^.Vrchol^.Prvky[1]^.Hodnota);
        pomocny := zaciatok;
        zaciatok := zaciatok^.Dalsi;
        //if zaciatok = nil then writeln('zaciatok je nil');                              
        Vyhod := tmp;                      
        dispose(pomocny);
        //writeln('uspesne som vyhodil ', tmp^.Vrchol^.Prvky[1]^.Hodnota);
    end;
end;

(*-------------------------------* VKLADANIE DO FRONTY *-------------------------------*)
{ // Na koniec fronty vlozi novy vrchol
// Vstupne hodnoty: Pointer na zaciatok (prvy prvok) a koniec (posledny prvok) fronty, Pointer na vrchol, ktory do fronty chceme ulozit
    // Zaciatok potrebujeme, aby sme ho mohli prepisat v pripade pridavania do prazdnej fronty }

procedure Vloz(var zaciatok: pFronta; vrchol: pVrchol; hlbka: longint); 
var tmp: pFronta; vsh: pVrcholSHlbkou;
begin
    new(vsh);
    vsh^.Vrchol := vrchol;
    vsh^.Hlbka := hlbka;
    //writeln('vkladam ', vrchol^.Prvky[1]^.Hodnota);
    new(tmp);
    tmp^.Vrchol := vsh;
    tmp^.Dalsi := zaciatok;
    zaciatok := tmp;   
end;



(*-------------------------------* VYPISOVANIE VRCHOLU *-------------------------------*)
{ // Vypise obsah vrcholu
// Vstupne data: Pointer na vrchol, ktory chceme vypisat; Boolean, ci mam vypisat do novej vrstvy }

procedure VypisVrchol(vrchol: pVrchol; hlbka: longint; jePosledny: boolean);
var i: longint;
begin
    for i := 1 to hlbka-1 do write('║');
    if jePosledny then write('╚')
    else if hlbka = 0 then
    else write('╠');
    if vrchol^.Prvky[1]^.Syn <> nil then write('╦» |')
    else write('═» |');
    if vrchol^.Prvky[1] <> nil then write(vrchol^.Prvky[1]^.Hodnota, '[', vrchol^.Prvky[1]^.Pocet, ']');
    if vrchol^.Prvky[2]^.Hodnota <> -1 then write(' , ', vrchol^.Prvky[2]^.Hodnota, '[', vrchol^.Prvky[2]^.Pocet, ']');
    writeln('|');
end;

(*-------------------------------* VYPISOVANIE STROMU *-------------------------------*)
{ // Samotna funkcia, ktora vypise obsah stromu
// Vstupne data: Koren 2-3 stromu, ktory chceme vypisat }

procedure VypisStrom(koren: pVrchol);
var
    zaciatok, koniec: pFronta;              { // Pointery na zaciatok/koniec fronty }
    vrcholSHlbkou: pVrcholSHlbkou;
    hlbka: longint;              { // Hlbka aktualneho vrcholu a hlbka predchadzajuceho spracovaneho vrcholu }
    vrchol: pVrchol;                        { // Vrchol, ktory aktualne spracovavam }
begin
    if koren = nil then exit();
    zaciatok := nil;
    Vloz(zaciatok, koren, 0);
    vrcholSHlbkou := Vyhod(zaciatok);                                   { // Vytiahnem si z fronty vrchol na spracovanie }                            
    while vrcholSHlbkou <> nil do                { // Fronta bude prazdna ked zaciatok bude nil }
    begin
        vrchol := vrcholSHlbkou^.Vrchol;                                            { // Extrahujem z neho jeho hlbku a samotny vrchol }
        hlbka := vrcholSHlbkou^.Hlbka;
        if (vrchol^.Prvky[2] <> nil) and (vrchol^.Prvky[2]^.Hodnota <> -1) and (vrchol^.Prvky[2]^.Syn <> nil) 
            then Vloz(zaciatok, vrchol^.Prvky[2]^.Syn, hlbka+1);
        if (vrchol^.Prvky[1] <> nil) and (vrchol^.Prvky[1]^.Syn <> nil)             { // Pri prvkoch sa musime pozriet, ci tie vobec existuju }
            then begin
            //writeln('hu' ,vrchol^.Prvky[1]^.Hodnota);
            Vloz(zaciatok, vrchol^.Prvky[1]^.Syn, hlbka+1);            { // Hlbka syna je vzdy o 1 vacsia }
            end;
        if vrchol^.Syn <> nil then Vloz(zaciatok, vrchol^.Syn, hlbka+1);    { // Kedze chceme prvky v spravnom poradi, do fronty vkladam existujuce vrcholy "zlava-doprava" }
        //writeln('hu' ,vrchol^.Prvky[1]^.Hodnota);
        vrcholSHlbkou := Vyhod(zaciatok);                                   { // Vytiahnem si z fronty novy vrchol na spracovanie }
        VypisVrchol(vrchol, hlbka, (vrcholSHlbkou <> nil) and (vrcholSHlbkou^.Hlbka < hlbka));                                                                                         
    end;
end;

end.