program test;

uses Strom23;

var koren: pVrchol;
    input: char;
    number: longint;

procedure napchajStromNahodnymiHodnotami(var koren: pVrchol; kolko: integer);
{ Zatial tam dava hodnoty 1-n, pretoze random dava az podozrivo vela rovnakych cisel }
var i: integer;
begin
    for i:=1 to kolko do 
    begin
        Strom23.Insert(koren, i);                            
    end;
end;

begin
    koren := Strom23.InitTree;
    while true do
    begin
        writeln('Ak si zelate...');
        writeln('...vlozit hodnotu, napiste "i [hodnota]"');
        writeln('...vlozit naraz viacero hodnot, napiste "b"');
        writeln('...vlozit naraz n hodnot, napiste "r [n]"');                           
        writeln('...vlozit hodnotu, napiste "p"');
        writeln('...vypnut program, napiste "q"');
        read(input);
        case input of
            'i':begin
                    readln(number);
                    if number >= 0 then Strom23.Insert(koren, number)
                    else writeln('ERROR: Vlozte nezaporne cislo!');
                end;
            'b':begin
                    writeln('pre ukoncenie rezimu napiste zaporne cislo');
                    read(number);
                    while number >= 0 do
                    begin
                        if number >= 0 then Strom23.Insert(koren, number);
                        read(number);
                    end
                end;
            'r':begin
                    readln(number);
                    napchajStromNahodnymiHodnotami(koren, number);
                end; 
            'p':begin
                    Strom23.VypisStrom(koren);
                end;
            'd':begin
                    readln(number);
                    Strom23.Delete(koren, number);
                end;
            'q': exit;
            else writeln('ERROR: Vlozte platnu moznost');
        end;
    end;

end.