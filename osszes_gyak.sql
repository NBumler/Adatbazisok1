-- 1. gyakorlat

-- SZERET tábla feladatok
SELECT * FROM szeret ORDER BY nev;
-- Melyek azok a gyümölcsök, amelyeket Micimackó szeret?
SELECT gyumolcs FROM szeret WHERE nev = 'Micimackó';
-- Melyek azok a gyümölcsök, amelyeket Micimackó nem szeret? (de valaki más igen)
SELECT DISTINCT gyumolcs FROM szeret MINUS SELECT gyumolcs FROM szeret WHERE nev = 'Micimackó';
-- Kik szeretik az almát?
SELECT nev FROM szeret WHERE gyumolcs = 'alma';
-- Kik nem szeretik a körtét? (de valami mást igen)
SELECT DISTINCT nev FROM szeret MINUS SELECT nev FROM szeret WHERE gyumolcs = 'körte';
-- Kik szeretik vagy az almát vagy a körtét?
SELECT DISTINCT nev FROM szeret WHERE gyumolcs = 'alma' OR gyumolcs = 'körte';
-- Kik szeretik az almát is és a körtét is?
SELECT sz1.nev FROM szeret sz1, szeret sz2 WHERE sz1.nev = sz2.nev AND (sz1.gyumolcs = 'alma' AND sz2.gyumolcs = 'körte');
-- Kik azok, akik szeretik az almát, de nem szeretik a körtét?
(SELECT nev FROM szeret WHERE gyumolcs = 'alma') INTERSECT (SELECT DISTINCT nev FROM szeret MINUS SELECT nev FROM szeret WHERE gyumolcs = 'körte');

-- 2. gyakorlat

-- DOLGOZO tábla feladatok
SELECT * FROM dolgozo;
-- Kik azok a dolgozók, akiknek a fizetése nagyobb, mint 2800?
SELECT dnev, fizetes FROM dolgozo WHERE fizetes > 2800;
-- Kik azok a dolgozók, akik a 10-es vagy a 20-as osztályon dolgoznak?
SELECT dnev, oazon FROM dolgozo WHERE oazon = 10 OR oazon = 20;
-- Kik azok, akiknek a jutaléka nagyobb, mint 600?
SELECT dnev, jutalek FROM dolgozo WHERE jutalek > 600;
-- Kik azok, akiknek a jutaléka nem nagyobb, mint 600?
SELECT dnev, jutalek FROM dolgozo WHERE jutalek <= 600;
-- Kik azok a dolgozók, akiknek a jutaléka ismeretlen (nincs kitöltve, vagyis NULL)?
SELECT dnev, jutalek FROM dolgozo WHERE jutalek IS NULL;
-- Másik megoldás, ami kihasználja, hogy a null nem kisebb vagy egyenlõ vagy nagyobb semminél:
SELECT dnev, jutalek FROM dolgozo MINUS (SELECT dnev, jutalek FROM dolgozo WHERE jutalek > 600 UNION SELECT dnev, jutalek FROM dolgozo WHERE jutalek <= 600);
-- Adjuk meg a dolgozók között elõforduló foglalkozások neveit.
SELECT DISTINCT foglalkozas FROM dolgozo WHERE foglalkozas IS NOT NULL;
-- Adjuk meg azoknak a nevét és kétszeres fizetését, akik a 10-es osztályon dolgoznak.
SELECT dnev, fizetes*2 FROM dolgozo WHERE oazon = 10;
-- Kik azok a dolgozók, akik 1982.01.01 után léptek be a céghez?
SELECT dnev, belepes FROM dolgozo WHERE belepes > TO_DATE('1982.01.01', 'YYYY.MM.DD');
-- Kik azok, akiknek nincs fõnöke?
SELECT dnev, fonoke FROM dolgozo WHERE fonoke IS NULL;
-- Másik megoldás: kivonom az összesbõl azokat, akiknek van fõnöke
(SELECT DISTINCT dnev FROM dolgozo) MINUS (SELECT d1.dnev FROM dolgozo d1, dolgozo d2 WHERE d1.fonoke = d2.dkod);
-- Kik azok a dolgozók, akiknek a fõnöke KING? (egyelõre leolvasva a képernyõrõl)
SELECT dnev FROM dolgozo WHERE fonoke = (SELECT dkod FROM dolgozo WHERE dnev = 'KING');
-- Relációs algebrában is mûködõ megoldás:
SELECT d1.dnev FROM dolgozo d1, dolgozo d2 WHERE d1.fonoke = d2.dkod AND d2.dnev = 'KING';

-- 3. gyakorlat

-- SZERET tábla feladatok
SELECT * FROM szeret ORDER BY nev;
-- Kik szeretnek legalább kétféle gyümölcsöt?
SELECT DISTINCT sz1.nev FROM szeret sz1, szeret sz2 WHERE sz1.nev = sz2.nev AND sz1.gyumolcs <> sz2.gyumolcs;
-- Kik szeretnek legalább háromféle gyümölcsöt?
SELECT DISTINCT sz1.nev FROM szeret sz1, szeret sz2, szeret sz3
    WHERE sz1.nev = sz2.nev AND sz2.nev = sz3.nev
        AND sz1.gyumolcs <> sz2.gyumolcs AND sz2.gyumolcs <> sz3.gyumolcs AND sz1.gyumolcs <> sz3.gyumolcs;
-- Kik szeretnek legfeljebb kétféle gyümölcsöt?
-- Azok szeretnek legfeljebb 2-t, akik nem szeretnek legfeljebb 3-at:
(SELECT nev FROM szeret)
    MINUS
        (SELECT DISTINCT sz1.nev FROM szeret sz1, szeret sz2, szeret sz3
            WHERE sz1.nev = sz2.nev
                AND sz2.nev = sz3.nev
                AND sz1.gyumolcs <> sz2.gyumolcs
                AND sz2.gyumolcs <> sz3.gyumolcs
                AND sz1.gyumolcs <> sz3.gyumolcs);
-- Kik szeretnek pontosan kétféle gyümölcsöt?
-- Azok akik legalább kettõt ÉS legfeljebb kettõt:
(SELECT DISTINCT sz1.nev FROM szeret sz1, szeret sz2 WHERE sz1.nev = sz2.nev AND sz1.gyumolcs <> sz2.gyumolcs)
    INTERSECT
(SELECT nev FROM szeret)
    MINUS
        (SELECT DISTINCT sz1.nev FROM szeret sz1, szeret sz2, szeret sz3
            WHERE sz1.nev = sz2.nev
                AND sz2.nev = sz3.nev
                AND sz1.gyumolcs <> sz2.gyumolcs
                AND sz2.gyumolcs <> sz3.gyumolcs
                AND sz1.gyumolcs <> sz3.gyumolcs);

-- DOLGOZO tábla feladatok
SELECT * FROM dolgozo;
-- Adjuk meg azoknak a fõnököknek a nevét, akiknek a foglalkozása nem 'MANAGER' (dnev)
SELECT DISTINCT d2.dnev, d2.foglalkozas FROM dolgozo d1, dolgozo d2
    WHERE d1.fonoke = d2.dkod AND d2.foglalkozas <> 'MANAGER';
-- Adjuk meg azokat a dolgozókat, akik többet keresnek a fõnöküknél.
SELECT d1.dnev, (d1.fizetes + d1.jutalek), d2.dnev, (d2.fizetes + d2.jutalek) FROM dolgozo d1, dolgozo d2
    WHERE d1.fonoke = d2.dkod AND (d1.fizetes + d1.jutalek) > (d2.fizetes + d2.jutalek);
-- Jutalékot nem nézve:
SELECT d1.dnev, d1.fizetes, d2.dnev, d2.fizetes FROM dolgozo d1, dolgozo d2
    WHERE d1.fonoke = d2.dkod AND d1.fizetes > d2.fizetes;
-- Kik azok a dolgozók, akik fõnökének a fõnöke KING?
SELECT d1.dnev FROM dolgozo d1, dolgozo d2, dolgozo d3
    WHERE d1.fonoke = d2.dkod AND d2.fonoke = d3.dkod AND d3.dnev = 'KING';
-- Kik azok a dolgozók, akik osztályának telephelye DALLAS vagy CHICAGO?
-- Ide kelleni fog az OSZTALY tábla is
SELECT * FROM osztaly;
SELECT * FROM dolgozo;
SELECT dnev FROM dolgozo NATURAL JOIN osztaly WHERE telephely = 'DALLAS' OR telephely = 'CHICAGO';
-- Kik azok a dolgozók, akik osztályának telephelye nem DALLAS és nem CHICAGO?
-- NULL értéket beleértve:
(SELECT dnev FROM dolgozo)
    MINUS
        (SELECT dnev FROM dolgozo NATURAL JOIN osztaly WHERE telephely = 'DALLAS' OR telephely = 'CHICAGO');
-- NULL értéket nem beleértve:
SELECT dnev FROM dolgozo NATURAL JOIN osztaly WHERE telephely <> 'DALLAS' AND telephely <> 'CHICAGO';
-- Adjuk meg azoknak a nevét, akiknek a fizetése > 2000 vagy a CHICAGO-i osztályon dolgoznak.
SELECT dnev, fizetes, telephely FROM dolgozo NATURAL JOIN osztaly WHERE fizetes > 2000 OR telephely = 'CHICAGO';
-- Melyik osztálynak nincs dolgozója?
SELECT oazon FROM osztaly MINUS SELECT oazon FROM dolgozo;
-- Adjuk meg azokat a dolgozókat, akiknek van 2000-nél nagyobb fizetésû beosztottja.
SELECT d2.dnev, d1.fizetes FROM dolgozo d1, dolgozo d2
    WHERE d1.fonoke = d2.dkod AND d1.fizetes > 2000;
-- Adjuk meg azokat a dolgozókat, akiknek nincs 2000-nél nagyobb fizetésû beosztottja.
(SELECT dnev FROM dolgozo)
    MINUS
        (SELECT d2.dnev FROM dolgozo d1, dolgozo d2
            WHERE d1.fonoke = d2.dkod AND d1.fizetes > 2000);
-- Adjuk meg azokat a telephelyeket, ahol van elemzõ (ANALYST) foglalkozású dolgozó.
SELECT DISTINCT telephely FROM dolgozo NATURAL JOIN osztaly WHERE foglalkozas = 'ANALYST';
-- Adjuk meg azokat a telephelyeket, ahol nincs elemzõ (ANALYST) foglalkozású dolgozó.
(SELECT telephely FROM osztaly) MINUS (SELECT DISTINCT telephely FROM dolgozo NATURAL JOIN osztaly WHERE foglalkozas = 'ANALYST');
-- Adjuk meg a maximális fizetésû dolgozó(k) nevét.
(SELECT dnev FROM dolgozo) MINUS (SELECT d1.dnev FROM dolgozo d1, dolgozo d2 WHERE d1.fizetes < d2.fizetes);

-- HAJOK, HAJOOSZTALYOK, CSATAK, KIMENETELEK tábla feladatok

-- Adjuk meg azokat a hajóosztályokat a gyártó országok nevével együtt, amelyeknek az ágyúi legalább 16-os kaliberûek.
SELECT * FROM hajok ORDER BY hajonev;
SELECT * FROM hajoosztalyok;
SELECT * FROM csatak;
SELECT * FROM kimenetelek ORDER BY csatanev;
-- Melyek azok a hajók, amelyeket 1921 elõtt avattak fel?
SELECT * FROM hajok WHERE felavatva < 1921;
-- Adjuk meg a Denmark Strait-csatában elsüllyedt hajók nevét.
SELECT hajonev, csatanev, eredmeny FROM kimenetelek WHERE csatanev = 'Denmark Strait' AND eredmeny = 'elsullyedt';
-- Az 1921-es washingtoni egyezmény betiltotta a 35000 tonnánál súlyosabb hajókat.
-- Adjuk meg azokat a hajókat, amelyek megszegték az egyezményt. (1921 után avatták fel õket)
SELECT hajonev, felavatva, vizkiszoritas FROM hajok JOIN hajoosztalyok ON hajok.osztaly = hajoosztalyok.osztaly
    WHERE hajok.felavatva > 1921 AND vizkiszoritas > 35000;
-- Adjuk meg a Guadalcanal csatában részt vett hajók nevét, vízkiszorítását és ágyúi­nak a számát.
SELECT hajonev, vizkiszoritas, agyukszama FROM hajoosztalyok NATURAL JOIN (SELECT * FROM kimenetelek NATURAL JOIN hajok WHERE csatanev = 'Guadalcanal');
-- Adjuk meg az adatbázisban szereplõ összes hadihajó nevét. (Ne feledjük, hogy a Hajók relációban nem feltétlenül szerepel az összes hajó!)
SELECT DISTINCT hajonev FROM ((SELECT hajonev FROM hajok) UNION (SELECT hajonev FROM kimenetelek));

-- 4. gyakorlat (zh)
-- 5. gyakorlat

-- SZERET tábla feladatok
SELECT * FROM szeret ORDER BY nev;
-- Kik szeretnek minden gyümölcsöt
-- Összeszorzom az összes nevet az összes gyümölccsel -> meglesz minden lehetséges változat.
-- Ebbõl kivonom a szeret táblát -> marad ami rossz. Projektálom névre, megvannak a rossz nevek.
-- Kivonom a rossz neveket az összes névbõl -> meglesznek a jó nevek
SELECT DISTINCT nev FROM szeret; -- összes név
SELECT DISTINCT gyumolcs FROM szeret; -- összes gyümölcs
SELECT * FROM (SELECT DISTINCT nev FROM szeret), (SELECT DISTINCT gyumolcs FROM szeret); -- összes lehetõség
(SELECT * FROM (SELECT DISTINCT nev FROM szeret), (SELECT DISTINCT gyumolcs FROM szeret))
    MINUS
(SELECT * FROM szeret); -- összes rossz név-gyülölcs
-- A megoldás:
(SELECT DISTINCT nev FROM szeret)
    MINUS
(SELECT nev FROM
    ((SELECT * FROM (SELECT DISTINCT nev FROM szeret), (SELECT DISTINCT gyumolcs FROM szeret))
        MINUS
    (SELECT * FROM szeret))); -- megoldás
-- Kik azok, akik legalább azokat a gyümölcsöket szeretik, mint Micimackó
-- Összes név x gyümölcs amit Micimackó szeret -> Micimackó gyümölcseivel összes lehetõség.
-- Kivonjuk belõle a szeret táblát -> olyan marad aki nem szereti azt amit Micimackó igen -> kivonjuk õket az eredeti nevekbõl
SELECT DISTINCT nev FROM szeret
    MINUS
SELECT nev FROM
    (SELECT * FROM (SELECT DISTINCT nev FROM szeret), (SELECT gyumolcs FROM szeret WHERE nev = 'Micimackó')
        MINUS
    (SELECT * FROM szeret));

-- Kik azok, akik legfeljebb azokat a gyümölcsöket szeretik, mint Micimackó
SELECT DISTINCT nev FROM szeret
    MINUS
SELECT nev FROM
    ((SELECT * FROM szeret)
        MINUS
    (SELECT * FROM (SELECT DISTINCT nev FROM szeret), (SELECT gyumolcs FROM szeret WHERE nev = 'Micimackó')));
-- Kik azok, akik pontosan azokat a gyümölcsöket szeretik, mint Micimackó
SELECT DISTINCT nev FROM szeret
    MINUS
SELECT nev FROM
    (SELECT * FROM (SELECT DISTINCT nev FROM szeret), (SELECT gyumolcs FROM szeret WHERE nev = 'Micimackó')
        MINUS
    (SELECT * FROM szeret))
    INTERSECT
SELECT DISTINCT nev FROM szeret
    MINUS
SELECT nev FROM
    ((SELECT * FROM szeret)
        MINUS
    (SELECT * FROM (SELECT DISTINCT nev FROM szeret), (SELECT gyumolcs FROM szeret WHERE nev = 'Micimackó')));

-- Függvények
-- DOLGOZO, FIZ_KATEGORIA tábla feladatok
SELECT * FROM dolgozo;
SELECT * FROM fiz_kategoria;
-- Kik azok a dolgozók, akik 1982.01.01 után léptek be a céghez?
SELECT * FROM dolgozo WHERE belepes > TO_DATE('1982.01.01', 'YYYY.MM.DD');
-- Adjuk meg azon dolgozókat, akik nevének második betûje A.
-- 2 megoldás:
SELECT * FROM dolgozo WHERE dnev LIKE '_A%';
SELECT * FROM dolgozo WHERE INSTR(dnev, 'A', 2, 1) = 2;
-- Adjuk meg azon dolgozókat, akik nevében van legalább két L betû.
-- 2 megoldás:
SELECT * FROM dolgozo WHERE dnev LIKE '%L%L%';
SELECT * FROM dolgozo WHERE INSTR(dnev, 'L', 1, 2) > 0;
-- Adjuk meg a dolgozók nevének utolsó három betûjét.
SELECT SUBSTR(dnev, -3, 3), dolgozo.* FROM dolgozo;
-- Adjuk meg a dolgozók fizetéseinek négyzetgyökét két tizedesre, és ennek egészrészét.
SELECT ROUND(SQRT(fizetes), 2), FLOOR(ROUND(SQRT(fizetes), 2)), dolgozo.* FROM dolgozo;
-- Adjuk meg, hogy hány napja dolgozik a cégnél ADAMS és milyen hónapban lépett be.
SELECT (SYSDATE - belepes), TO_CHAR(belepes, 'month'), dolgozo.* FROM dolgozo WHERE dnev = 'ADAMS';
-- Adjuk meg azokat a (név, fõnök) párokat, ahol a két ember neve ugyanannyi betûbõl áll.
SELECT d1.dnev, d2.dnev FROM dolgozo d1 JOIN dolgozo d2 ON d1.fonoke = d2.dkod WHERE LENGTH(d1.dnev) = LENGTH(d2.dnev);
-- Listázzuk ki a dolgozók nevét és fizetését, valamint jelenítsük meg a fizetést grafikusan úgy,
-- hogy a fizetést 1000 Ft-ra kerekítve, minden 1000 Ft-ot egy # jel jelöl.
SELECT dnev, fizetes, RPAD(' ', (fizetes/1000)+1, '#') FROM dolgozo;
-- Listázzuk ki azoknak a dolgozóknak a nevét, fizetését, jutalékát, és a jutalék/fizetés arányát,
-- akiknek a foglalkozása eladó (salesman). Az arányt két tizedesen jelenítsük meg.
SELECT dnev, fizetes, jutalek, ROUND(jutalek/fizetes, 2) FROM dolgozo WHERE LOWER(foglalkozas) = 'salesman';

-- Csoportképzés

-- Adjuk meg mennyi a dolgozók között elõforduló maximális fizetés.
SELECT MAX(fizetes) FROM dolgozo;
-- Adjuk meg mennyi a dolgozók között elõforduló minimális fizetés.
SELECT MIN(fizetes) FROM dolgozo;
-- Adjuk meg mennyi a dolgozók között elõforduló átlagfizetés.
SELECT AVG(fizetes) FROM dolgozo;
-- Adjuk meg a dolgozó tábla sorainak számát.
SELECT COUNT(*) FROM dolgozo;
-- Adjuk meg hányan dolgoznak az egyes osztályokon.
SELECT oazon, COUNT(*) FROM dolgozo GROUP BY oazon ORDER BY oazon;
-- Adjuk meg azokra az osztályokra az átlagfizetést, ahol ez nagyobb mint 2000.
SELECT oazon, AVG(fizetes) FROM dolgozo
    GROUP BY oazon
    HAVING AVG(fizetes) > 2000
    ORDER BY oazon;
-- Adjuk meg az átlagfizetést azokon az osztályokon, ahol legalább 4-en dolgoznak (oazon, avg_fiz)
SELECT oazon, AVG(fizetes) FROM dolgozo
    GROUP BY oazon
    HAVING count(*) >= 3
    ORDER BY oazon;
-- Adjuk meg az átlagfizetést és telephelyet azokon az osztályokon, ahol legalább 4-en dolgoznak.
SELECT oazon, telephely, AVG(fizetes) FROM (dolgozo NATURAL JOIN osztaly)
    GROUP BY oazon, telephely
    HAVING count(*) >= 4;
-- Adjuk meg azon osztályok nevét és telephelyét, ahol az átlagfizetés nagyobb mint 2000. (onev, telephely)
SELECT onev, telephely
    FROM dolgozo NATURAL JOIN osztaly
    GROUP BY onev, telephely
    HAVING AVG(fizetes) > 2000;
-- Adjuk meg azokat a fizetési kategóriákat, amelybe pontosan 3 dolgozó fizetése esik.
-- Új kódolási stílust használok mostantól
SELECT kategoria
FROM (dolgozo JOIN fiz_kategoria ON dolgozo.fizetes BETWEEN fiz_kategoria.also AND fiz_kategoria.felso)
GROUP BY kategoria
HAVING count(*) = 3
ORDER BY kategoria;
-- Adjuk meg azokat a fizetési kategóriákat, amelyekbe esõ dolgozók mindannyian ugyanazon az osztályon dolgoznak.


-- Adjuk meg azon osztályok nevét és telephelyét, amelyeknek van 1-es fizetési kategóriájú dolgozója.

-- Adjuk meg azon osztályok nevét és telephelyét, amelyeknek legalább 2 fõ 1-es fiz. kategóriájú dolgozója van.

-- Készítsünk listát a páros és páratlan azonosítójú (dkod) dolgozók számáról.

-- Listázzuk ki munkakörönként a dolgozók számát, átlagfizetését (kerekítve) numerikusan és grafikusan is. 200-anként jelenítsünk meg egy #-ot
