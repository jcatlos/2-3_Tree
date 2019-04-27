unit Strom23_Delete;

{ V tomto subore sa nachadza funkcia Delete, ktora vymaze zadany prvok zo stromu }

interface

uses Strom23_Typy, Strom23_Vypis;

procedure Delete(var koren: pVrchol; hodnota: longint);

implementation

procedure VymenInt(var a:longint; var b:longint);
var c: longint;
begin
    c := a;
    a := b;
    b := c;
end;

procedure VymenPVrchol(var a:pVrchol; var b:pVrchol);
var c: pVrchol;
begin
    c := a;
    a := b;
    b := c;
end;


procedure DisPravy(rodic, ja, brat: pVrchol); // Voloam iba ak som prvy syn vo vrchole - ink volam DisLavy - moj vrchol je uz prazdny - inak by som toto nevolal - Pred zavolanim overim, ci mam rodica a brata s 2 prvkami
begin 
    VymenInt(ja^.Prvky[1]^.Hodnota, rodic^.Prvky[1]^.Hodnota);      {Prvy prvok v rodicovi premiestnim do seba}
    VymenInt(ja^.Prvky[1]^.Pocet, rodic^.Prvky[1]^.Pocet);
    ja^.Prvky[1]^.Syn := brat^.Syn;                                 {Synom tohoto prvku sa stane bratov syn}
    if brat^.Syn <> nil then ja^.Prvky[1]^.Syn^.Rodic := ja;
    brat^.Syn := brat^.Prvky[1]^.Syn;                               {1. prvok v bratovi ide do rodica, takze jeho syn sa stane synom vrcholu - Su v nom prvky mensie ako prvky 2. prvku}


    VymenInt(brat^.Prvky[1]^.Hodnota, rodic^.Prvky[1]^.Hodnota);      {Prvy prvok v bratovi premiestnim do rodica}
    VymenInt(brat^.Prvky[1]^.Pocet, rodic^.Prvky[1]^.Pocet);

    VymenPrvky(brat^.Prvky[1], brat^.Prvky[2]);                         {Vo mne je nil, takze ho chcem mat na 2. pozicii vo vrchole}
    dispose(brat^.Prvky[2]);
    brat^.Prvky[2] := PrazdnyPrvok;
    writeln('Rozdistribuoval som zprava');
end;

procedure DisLavy(rodic, ja, brat: pVrchol; pozicia: integer); // Voloam iba ak nie som prvy syn vo vrchole - inak volam DisPravy - moj vrchol je uz prazdny - inak by som toto nevolal - Pred zavolanim overim, ci mam rodica a brata s 2 prvkami + beriem, ktory syn som
begin
    VymenInt(ja^.Prvky[1]^.Hodnota, rodic^.Prvky[pozicia]^.Hodnota);      {Prvy prvok v rodicovi premiestnim do seba}
    VymenInt(ja^.Prvky[1]^.Pocet, rodic^.Prvky[pozicia]^.Pocet);          {Pozicia -> ak som prvy prvok, tak pouzivam prvy prvok rodica; ak som druhy pouzivam druhy prvok rodica}
    
    ja^.Prvky[1]^.Syn := ja^.Syn;
    ja^.Syn := brat^.Prvky[2]^.Syn;                                 {Synom tohoto prvku sa stane bratov syn}
    if ja^.Syn <> nil then ja^.Syn^.Rodic := ja;
    dispose(brat^.Prvky[2]);
    brat^.Prvky[2] := PrazdnyPrvok;                                     {Tento prvok uz nema syna}

    VymenInt(brat^.Prvky[2]^.Hodnota, rodic^.Prvky[pozicia]^.Hodnota);      {Druhy prvok v bratovi premiestnim do rodica}
    VymenInt(brat^.Prvky[2]^.Pocet, rodic^.Prvky[pozicia]^.Pocet);
    writeln('Rozdistribuoval som zlava');
end;

procedure Spoj(rodic: pPrvok; var vacsi: pVrchol; mensi: pVrchol);
begin
    if rodic = nil then writeln('rodic nil');
    if mensi^.Prvky[1]^.Hodnota = -1 then
    begin
        writeln('zacinam prehadzovat');
        VymenInt(mensi^.Prvky[1]^.Hodnota, rodic^.Hodnota);
        VymenInt(mensi^.Prvky[1]^.Pocet, rodic^.Pocet);
        mensi^.Prvky[1]^.Syn := vacsi^.Syn;
        mensi^.Prvky[2] := vacsi^.Prvky[1];
        if vacsi^.Syn <> nil then vacsi^.Syn^.Rodic := mensi;
        if vacsi^.Prvky[1]^.Syn <> nil then vacsi^.Prvky[1]^.Syn^.Rodic := mensi;
        writeln('prehodil som');
    end
    else
    begin
        writeln('zacinam prehadzovat');
        writeln('boop');
        if vacsi^.Syn <> nil then vacsi^.Syn^.Rodic := mensi;
        VymenInt(mensi^.Prvky[2]^.Hodnota, rodic^.Hodnota);
        VymenInt(mensi^.Prvky[2]^.Pocet, rodic^.Pocet);
        mensi^.Prvky[2]^.Syn := vacsi^.Syn;
        writeln('prehodil som');
    end;                                                            {Vsetko je v mensom synovy, mozeme zacat riesit mazanie}
    dispose(vacsi);                                                 {brata uz nepotrebujeme}
    if mensi^.Rodic^.Prvky[1]^.Hodnota = -1 then VymenPrvky(mensi^.Rodic^.Prvky[1], mensi^.Rodic^.Prvky[2]);
    writeln('spojil som');
end;

function NajdiMinimumVPodstrome(koren:pVrchol):pPrvok;
var vrchol: pVrchol;
begin
    vrchol := koren;
    while vrchol^.Syn <> nil do vrchol := vrchol^.Syn;
    NajdiMinimumVPodstrome := vrchol^.Prvky[1];
end;

procedure Zmaz(var koren: pVrchol; hodnota: longint);
var 
    mazem: integer; 
    vrchol, ja, brat, pomSyn: pVrchol; 
    pomPrvok: pPrvok;
begin
    if koren = nil then exit();                                                                  {Hodnota v strome nie je}
    vrchol := koren;
    mazem := 0;
    {Najprv chceme vo vrchole najst prvok, ktory chceme mazat}                                                                        
    if hodnota = vrchol^.Prvky[1]^.Hodnota then                                                 {Ak je hodnota ulozena v prvom prvku}
    begin
        if vrchol^.Prvky[1]^.Pocet > 1 then
        begin
            vrchol^.Prvky[1]^.Pocet := vrchol^.Prvky[1]^.Pocet-1;
            exit();
        end;
        if vrchol^.Prvky[1]^.Syn = nil then
        begin
            writeln('MAZEM');
            vrchol^.Prvky[1] := PrazdnyPrvok;
            VymenPrvky(vrchol^.Prvky[1], vrchol^.Prvky[2]);
        end
        else
        begin
            pomPrvok := NajdiMinimumVPodstrome(vrchol^.Prvky[1]^.Syn);                                                 {Ak hodnota nie je v liste, vymenim prvok za minimum v jeho podstrome}
            if pomPrvok = nil then exit();
            VymenInt(pomPrvok^.Hodnota, vrchol^.Prvky[1]^.Hodnota);
            VymenInt(pomPrvok^.Pocet, vrchol^.Prvky[1]^.Pocet);
            { pomSyn := vrchol^.Prvky[1]^.Syn;  }                                                           {Vymenim ho s najdenou hodnotou a tu potom zmazem}
            { VymenPrvky(vrchol^.Prvky[1], pomPrvok);   }                                              {-> Pri vymienani prvkov si musim zapamatat syna a toho potom vratit naspat}
            { vrchol^.Prvky[1]^.Syn := pomSyn;
            pomPrvok^.Syn := nil;  }                                                                      {pomPrvok je v liste, takze syn je nil}
            Strom23_Vypis.VypisStrom(koren);
            Zmaz(vrchol^.Prvky[1]^.Syn, hodnota);   
            mazem := 1;
        end;
    end                                       
    else if hodnota = vrchol^.Prvky[2]^.Hodnota then                                            {Ak je hodnota ulozena v druhom prvku}
    begin
        if vrchol^.Prvky[2]^.Pocet > 1 then
        begin
            vrchol^.Prvky[2]^.Pocet := vrchol^.Prvky[2]^.Pocet-1;
            exit();
        end;
        if vrchol^.Prvky[2]^.Syn = nil then
        begin
            writeln('MAZEM');
            vrchol^.Prvky[2] := PrazdnyPrvok;
        end
        else
        begin
            pomPrvok := NajdiMinimumVPodstrome(vrchol^.Prvky[2]^.Syn);                                                 {Ak hodnota nie je v liste, vymenim prvok za minimum v jeho podstrome}
            if pomPrvok = nil then exit();
            VymenInt(pomPrvok^.Hodnota, vrchol^.Prvky[2]^.Hodnota);
            VymenInt(pomPrvok^.Pocet, vrchol^.Prvky[2]^.Pocet);
            { pomSyn := vrchol^.Prvky[2]^.Syn;  }                                                           {Vymenim ho s najdenou hodnotou a tu potom zmazem}
            { VymenPrvky(vrchol^.Prvky[2], pomPrvok); }                                                {-> Pri vymienani prvkov si musim zapamatat syna a toho potom vratit naspat}
            { vrchol^.Prvky[2]^.Syn := pomSyn;
            pomPrvok^.Syn := nil;  }                                                                      {pomPrvok je v liste, takze syn je nil}
            Strom23_Vypis.VypisStrom(koren);
            Zmaz(vrchol^.Prvky[2]^.Syn, hodnota);   
            mazem := 2;
        end;
    end
    else if hodnota < vrchol^.Prvky[1]^.Hodnota then                                            {Hladana hodnota je mensia ako vsetky hodnoty vo vrchole}
    begin
        Zmaz(vrchol^.Syn, hodnota);
        mazem := 0;                                                                             {mazem nastavim na zaklade toho, z ktoreho syna som mazal}
    end                     
    else if (vrchol^.Prvky[2]^.Hodnota <> -1) and (hodnota > vrchol^.Prvky[2]^.Hodnota) then    {Hladana hodnota je vacsia ako vsetky (existujuce) hodnoty vo vrchole}
    begin
        Zmaz(vrchol^.Prvky[2]^.Syn, hodnota);
        mazem := 2;
    end
    else if hodnota > vrchol^.Prvky[1]^.Hodnota then                                              {Hladana hodnota je vacsia ako hodnota prveho prvku}
    begin
        Zmaz(vrchol^.Prvky[1]^.Syn, hodnota); 
        mazem := 1;
    end;
    writeln('zacinam opravovat, vrciam sa z ', mazem);                                                                                            {Kontrolujem, ci som nevyprazdnil syna, z ktoreho som mazal}
    writeln('Som vo vrchole ',vrchol^.Prvky[1]^.Hodnota);
    if vrchol^.Syn <> nil then                                                                          {Synov opravujem z rodica, takze ak som v liste, takze ak som v liste, tento krok preskocim}
    begin
        writeln('moj syn je ',vrchol^.Prvky[1]^.Syn^.Prvky[1]^.Hodnota);
        if mazem = 0 then                                                                               {Ak som z 0. syna}
        begin
            if vrchol^.Syn^.Prvky[1]^.Hodnota = -1 then
            begin
                ja := vrchol^.Syn;
                brat := vrchol^.Prvky[1]^.Syn;   
                if brat^.Prvky[2]^.Hodnota <> -1 then                                                  {Ak ma brat prvok navyse}
                begin
                    writeln('spajam s pravym');
                    DisPravy(vrchol, ja, brat);                                                    {-> Beriem od brata}
                end
                else 
                begin
                    writeln('spajam');
                    Spoj(vrchol^.Prvky[1], brat, ja);                                              {Inak: -> Spajam sa s bratom - brat je napravo odo mna}
                end;
            end;
        end   
        else                                                                                             {Ak som z ineho syna}
        begin
            if vrchol^.Prvky[mazem]^.Syn^.Prvky[1]^.Hodnota = -1 then
            begin
                ja := vrchol^.Prvky[mazem]^.Syn;
                if mazem = 1 then brat := vrchol^.Syn
                else brat := vrchol^.Prvky[1]^.Syn;
                if brat^.Prvky[2]^.Hodnota <> -1  then                                                  {Ak ma brat prvok navyse}
                begin
                    writeln('spajam s lavym');
                    DisLavy(vrchol, ja, brat, mazem);                                                    {-> Beriem od brata}
                end
                else 
                begin
                    writeln('spajam');
                    Spoj(vrchol^.Prvky[mazem], ja, brat);                                              {Inak: -> Spajam sa s bratom - brat je nalavo odo mna}
                end;                                                       
            end;
        end;
    end;
end;

procedure Delete(var koren: pVrchol; hodnota: longint);
var pomVrchol: pVrchol;
begin
    if (hodnota < 0) or (koren = nil) then exit();                                             {V strome nedrzime zaporne hodnoty a v prazdnom strome hodnotu zarucene nenajdeme}
    Zmaz(koren, hodnota);
    writeln('Zmazal som');
    if koren^.Prvky[1]^.Hodnota = -1 then
    begin
        if koren^.Syn = nil then
        begin
            dispose(koren);
            koren := nil;
        end
        else if koren^.Syn^.Prvky[1]^.Hodnota <> -1 then
        begin
            pomVrchol := koren;
            koren:= koren^.Syn;
            dispose(pomVrchol);
            koren^.Rodic := nil;
        end
        else if koren^.Prvky[1]^.Syn^.Prvky[1]^.Hodnota <> -1 then                                                       {  DOPLN CO SA STANE AK KOREN MA LEN JEDNOHO SYNA  }
        begin
            pomVrchol := koren;
            koren:= koren^.Prvky[1]^.Syn;
            dispose(pomVrchol);
            koren^.Rodic := nil;    
        end;
    end;
end;


end.