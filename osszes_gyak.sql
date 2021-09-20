-- 1. gyakorlat

-- SZERET t�bla feladatok
SELECT * FROM szeret ORDER BY nev;
-- Melyek azok a gy�m�lcs�k, amelyeket Micimack� szeret?
SELECT gyumolcs FROM szeret WHERE nev = 'Micimack�';
-- Melyek azok a gy�m�lcs�k, amelyeket Micimack� nem szeret? (de valaki m�s igen)
SELECT DISTINCT gyumolcs FROM szeret MINUS SELECT gyumolcs FROM szeret WHERE nev = 'Micimack�';
-- Kik szeretik az alm�t?
SELECT nev FROM szeret WHERE gyumolcs = 'alma';
-- Kik nem szeretik a k�rt�t? (de valami m�st igen)
SELECT DISTINCT nev FROM szeret MINUS SELECT nev FROM szeret WHERE gyumolcs = 'k�rte';
-- Kik szeretik vagy az alm�t vagy a k�rt�t?
SELECT DISTINCT nev FROM szeret WHERE gyumolcs = 'alma' OR gyumolcs = 'k�rte';
-- Kik szeretik az alm�t is �s a k�rt�t is?
SELECT sz1.nev FROM szeret sz1, szeret sz2 WHERE sz1.nev = sz2.nev AND (sz1.gyumolcs = 'alma' AND sz2.gyumolcs = 'k�rte');
-- Kik azok, akik szeretik az alm�t, de nem szeretik a k�rt�t?
(SELECT nev FROM szeret WHERE gyumolcs = 'alma') INTERSECT (SELECT DISTINCT nev FROM szeret MINUS SELECT nev FROM szeret WHERE gyumolcs = 'k�rte');

-- 2. gyakorlat

-- DOLGOZO t�bla feladatok
SELECT * FROM dolgozo;
-- Kik azok a dolgoz�k, akiknek a fizet�se nagyobb, mint 2800?
SELECT dnev, fizetes FROM dolgozo WHERE fizetes > 2800;
-- Kik azok a dolgoz�k, akik a 10-es vagy a 20-as oszt�lyon dolgoznak?
SELECT dnev, oazon FROM dolgozo WHERE oazon = 10 OR oazon = 20;
-- Kik azok, akiknek a jutal�ka nagyobb, mint 600?
SELECT dnev, jutalek FROM dolgozo WHERE jutalek > 600;
-- Kik azok, akiknek a jutal�ka nem nagyobb, mint 600?
SELECT dnev, jutalek FROM dolgozo WHERE jutalek <= 600;
-- Kik azok a dolgoz�k, akiknek a jutal�ka ismeretlen (nincs kit�ltve, vagyis NULL)?
SELECT dnev, jutalek FROM dolgozo WHERE jutalek IS NULL;
-- M�sik megold�s, ami kihaszn�lja, hogy a null nem kisebb vagy egyenl� vagy nagyobb semmin�l:
SELECT dnev, jutalek FROM dolgozo MINUS (SELECT dnev, jutalek FROM dolgozo WHERE jutalek > 600 UNION SELECT dnev, jutalek FROM dolgozo WHERE jutalek <= 600);
-- Adjuk meg a dolgoz�k k�z�tt el�fordul� foglalkoz�sok neveit.
SELECT DISTINCT foglalkozas FROM dolgozo WHERE foglalkozas IS NOT NULL;
-- Adjuk meg azoknak a nev�t �s k�tszeres fizet�s�t, akik a 10-es oszt�lyon dolgoznak.
SELECT dnev, fizetes*2 FROM dolgozo WHERE oazon = 10;
-- Kik azok a dolgoz�k, akik 1982.01.01 ut�n l�ptek be a c�ghez?
SELECT dnev, belepes FROM dolgozo WHERE belepes > TO_DATE('1982.01.01', 'YYYY.MM.DD');
-- Kik azok, akiknek nincs f�n�ke?
SELECT dnev, fonoke FROM dolgozo WHERE fonoke IS NULL;
-- M�sik megold�s: kivonom az �sszesb�l azokat, akiknek van f�n�ke
(SELECT DISTINCT dnev FROM dolgozo) MINUS (SELECT d1.dnev FROM dolgozo d1, dolgozo d2 WHERE d1.fonoke = d2.dkod);
-- Kik azok a dolgoz�k, akiknek a f�n�ke KING? (egyel�re leolvasva a k�perny�r�l)
SELECT dnev FROM dolgozo WHERE fonoke = (SELECT dkod FROM dolgozo WHERE dnev = 'KING');
-- Rel�ci�s algebr�ban is m�k�d� megold�s:
SELECT d1.dnev FROM dolgozo d1, dolgozo d2 WHERE d1.fonoke = d2.dkod AND d2.dnev = 'KING';

-- 3. gyakorlat

-- SZERET t�bla feladatok
SELECT * FROM szeret ORDER BY nev;
-- Kik szeretnek legal�bb k�tf�le gy�m�lcs�t?
SELECT DISTINCT sz1.nev FROM szeret sz1, szeret sz2 WHERE sz1.nev = sz2.nev AND sz1.gyumolcs <> sz2.gyumolcs;
-- Kik szeretnek legal�bb h�romf�le gy�m�lcs�t?
SELECT DISTINCT sz1.nev FROM szeret sz1, szeret sz2, szeret sz3
    WHERE sz1.nev = sz2.nev AND sz2.nev = sz3.nev
        AND sz1.gyumolcs <> sz2.gyumolcs AND sz2.gyumolcs <> sz3.gyumolcs AND sz1.gyumolcs <> sz3.gyumolcs;
-- Kik szeretnek legfeljebb k�tf�le gy�m�lcs�t?
-- Azok szeretnek legfeljebb 2-t, akik nem szeretnek legfeljebb 3-at:
(SELECT nev FROM szeret)
    MINUS
        (SELECT DISTINCT sz1.nev FROM szeret sz1, szeret sz2, szeret sz3
            WHERE sz1.nev = sz2.nev
                AND sz2.nev = sz3.nev
                AND sz1.gyumolcs <> sz2.gyumolcs
                AND sz2.gyumolcs <> sz3.gyumolcs
                AND sz1.gyumolcs <> sz3.gyumolcs);
-- Kik szeretnek pontosan k�tf�le gy�m�lcs�t?
-- Azok akik legal�bb kett�t �S legfeljebb kett�t:
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

-- DOLGOZO t�bla feladatok
SELECT * FROM dolgozo;
-- Adjuk meg azoknak a f�n�k�knek a nev�t, akiknek a foglalkoz�sa nem 'MANAGER' (dnev)
SELECT DISTINCT d2.dnev, d2.foglalkozas FROM dolgozo d1, dolgozo d2
    WHERE d1.fonoke = d2.dkod AND d2.foglalkozas <> 'MANAGER';
-- Adjuk meg azokat a dolgoz�kat, akik t�bbet keresnek a f�n�k�kn�l.
SELECT d1.dnev, (d1.fizetes + d1.jutalek), d2.dnev, (d2.fizetes + d2.jutalek) FROM dolgozo d1, dolgozo d2
    WHERE d1.fonoke = d2.dkod AND (d1.fizetes + d1.jutalek) > (d2.fizetes + d2.jutalek);
-- Jutal�kot nem n�zve:
SELECT d1.dnev, d1.fizetes, d2.dnev, d2.fizetes FROM dolgozo d1, dolgozo d2
    WHERE d1.fonoke = d2.dkod AND d1.fizetes > d2.fizetes;
-- Kik azok a dolgoz�k, akik f�n�k�nek a f�n�ke KING?
SELECT d1.dnev FROM dolgozo d1, dolgozo d2, dolgozo d3
    WHERE d1.fonoke = d2.dkod AND d2.fonoke = d3.dkod AND d3.dnev = 'KING';
-- Kik azok a dolgoz�k, akik oszt�ly�nak telephelye DALLAS vagy CHICAGO?
-- Ide kelleni fog az OSZTALY t�bla is
SELECT * FROM osztaly;
SELECT * FROM dolgozo;
SELECT dnev FROM dolgozo NATURAL JOIN osztaly WHERE telephely = 'DALLAS' OR telephely = 'CHICAGO';
-- Kik azok a dolgoz�k, akik oszt�ly�nak telephelye nem DALLAS �s nem CHICAGO?
-- NULL �rt�ket bele�rtve:
(SELECT dnev FROM dolgozo)
    MINUS
        (SELECT dnev FROM dolgozo NATURAL JOIN osztaly WHERE telephely = 'DALLAS' OR telephely = 'CHICAGO');
-- NULL �rt�ket nem bele�rtve:
SELECT dnev FROM dolgozo NATURAL JOIN osztaly WHERE telephely <> 'DALLAS' AND telephely <> 'CHICAGO';
-- Adjuk meg azoknak a nev�t, akiknek a fizet�se > 2000 vagy a CHICAGO-i oszt�lyon dolgoznak.
SELECT dnev, fizetes, telephely FROM dolgozo NATURAL JOIN osztaly WHERE fizetes > 2000 OR telephely = 'CHICAGO';
-- Melyik oszt�lynak nincs dolgoz�ja?
SELECT oazon FROM osztaly MINUS SELECT oazon FROM dolgozo;
-- Adjuk meg azokat a dolgoz�kat, akiknek van 2000-n�l nagyobb fizet�s� beosztottja.
SELECT d2.dnev, d1.fizetes FROM dolgozo d1, dolgozo d2
    WHERE d1.fonoke = d2.dkod AND d1.fizetes > 2000;
-- Adjuk meg azokat a dolgoz�kat, akiknek nincs 2000-n�l nagyobb fizet�s� beosztottja.
(SELECT dnev FROM dolgozo)
    MINUS
        (SELECT d2.dnev FROM dolgozo d1, dolgozo d2
            WHERE d1.fonoke = d2.dkod AND d1.fizetes > 2000);
-- Adjuk meg azokat a telephelyeket, ahol van elemz� (ANALYST) foglalkoz�s� dolgoz�.
SELECT DISTINCT telephely FROM dolgozo NATURAL JOIN osztaly WHERE foglalkozas = 'ANALYST';
-- Adjuk meg azokat a telephelyeket, ahol nincs elemz� (ANALYST) foglalkoz�s� dolgoz�.
(SELECT telephely FROM osztaly) MINUS (SELECT DISTINCT telephely FROM dolgozo NATURAL JOIN osztaly WHERE foglalkozas = 'ANALYST');
-- Adjuk meg a maxim�lis fizet�s� dolgoz�(k) nev�t.
(SELECT dnev FROM dolgozo) MINUS (SELECT d1.dnev FROM dolgozo d1, dolgozo d2 WHERE d1.fizetes < d2.fizetes);

-- HAJOK, HAJOOSZTALYOK, CSATAK, KIMENETELEK t�bla feladatok

-- Adjuk meg azokat a haj�oszt�lyokat a gy�rt� orsz�gok nev�vel egy�tt, amelyeknek az �gy�i legal�bb 16-os kaliber�ek.
SELECT * FROM hajok ORDER BY hajonev;
SELECT * FROM hajoosztalyok;
SELECT * FROM csatak;
SELECT * FROM kimenetelek ORDER BY csatanev;
-- Melyek azok a haj�k, amelyeket 1921 el�tt avattak fel?
SELECT * FROM hajok WHERE felavatva < 1921;
-- Adjuk meg a Denmark Strait-csat�ban els�llyedt haj�k nev�t.
SELECT hajonev, csatanev, eredmeny FROM kimenetelek WHERE csatanev = 'Denmark Strait' AND eredmeny = 'elsullyedt';
-- Az 1921-es washingtoni egyezm�ny betiltotta a 35000 tonn�n�l s�lyosabb haj�kat.
-- Adjuk meg azokat a haj�kat, amelyek megszegt�k az egyezm�nyt. (1921 ut�n avatt�k fel �ket)
SELECT hajonev, felavatva, vizkiszoritas FROM hajok JOIN hajoosztalyok ON hajok.osztaly = hajoosztalyok.osztaly
    WHERE hajok.felavatva > 1921 AND vizkiszoritas > 35000;
-- Adjuk meg a Guadalcanal csat�ban r�szt vett haj�k nev�t, v�zkiszor�t�s�t �s �gy�i�nak a sz�m�t.
SELECT hajonev, vizkiszoritas, agyukszama FROM hajoosztalyok NATURAL JOIN (SELECT * FROM kimenetelek NATURAL JOIN hajok WHERE csatanev = 'Guadalcanal');
-- Adjuk meg az adatb�zisban szerepl� �sszes hadihaj� nev�t. (Ne feledj�k, hogy a Haj�k rel�ci�ban nem felt�tlen�l szerepel az �sszes haj�!)
SELECT DISTINCT hajonev FROM ((SELECT hajonev FROM hajok) UNION (SELECT hajonev FROM kimenetelek));

-- 4. gyakorlat (zh)
-- 5. gyakorlat

-- SZERET t�bla feladatok
SELECT * FROM szeret ORDER BY nev;
-- Kik szeretnek minden gy�m�lcs�t
-- �sszeszorzom az �sszes nevet az �sszes gy�m�lccsel -> meglesz minden lehets�ges v�ltozat.
-- Ebb�l kivonom a szeret t�bl�t -> marad ami rossz. Projekt�lom n�vre, megvannak a rossz nevek.
-- Kivonom a rossz neveket az �sszes n�vb�l -> meglesznek a j� nevek
SELECT DISTINCT nev FROM szeret; -- �sszes n�v
SELECT DISTINCT gyumolcs FROM szeret; -- �sszes gy�m�lcs
SELECT * FROM (SELECT DISTINCT nev FROM szeret), (SELECT DISTINCT gyumolcs FROM szeret); -- �sszes lehet�s�g
(SELECT * FROM (SELECT DISTINCT nev FROM szeret), (SELECT DISTINCT gyumolcs FROM szeret))
    MINUS
(SELECT * FROM szeret); -- �sszes rossz n�v-gy�l�lcs
-- A megold�s:
(SELECT DISTINCT nev FROM szeret)
    MINUS
(SELECT nev FROM
    ((SELECT * FROM (SELECT DISTINCT nev FROM szeret), (SELECT DISTINCT gyumolcs FROM szeret))
        MINUS
    (SELECT * FROM szeret))); -- megold�s
-- Kik azok, akik legal�bb azokat a gy�m�lcs�ket szeretik, mint Micimack�
-- �sszes n�v x gy�m�lcs amit Micimack� szeret -> Micimack� gy�m�lcseivel �sszes lehet�s�g.
-- Kivonjuk bel�le a szeret t�bl�t -> olyan marad aki nem szereti azt amit Micimack� igen -> kivonjuk �ket az eredeti nevekb�l
SELECT DISTINCT nev FROM szeret
    MINUS
SELECT nev FROM
    (SELECT * FROM (SELECT DISTINCT nev FROM szeret), (SELECT gyumolcs FROM szeret WHERE nev = 'Micimack�')
        MINUS
    (SELECT * FROM szeret));

-- Kik azok, akik legfeljebb azokat a gy�m�lcs�ket szeretik, mint Micimack�
SELECT DISTINCT nev FROM szeret
    MINUS
SELECT nev FROM
    ((SELECT * FROM szeret)
        MINUS
    (SELECT * FROM (SELECT DISTINCT nev FROM szeret), (SELECT gyumolcs FROM szeret WHERE nev = 'Micimack�')));
-- Kik azok, akik pontosan azokat a gy�m�lcs�ket szeretik, mint Micimack�
SELECT DISTINCT nev FROM szeret
    MINUS
SELECT nev FROM
    (SELECT * FROM (SELECT DISTINCT nev FROM szeret), (SELECT gyumolcs FROM szeret WHERE nev = 'Micimack�')
        MINUS
    (SELECT * FROM szeret))
    INTERSECT
SELECT DISTINCT nev FROM szeret
    MINUS
SELECT nev FROM
    ((SELECT * FROM szeret)
        MINUS
    (SELECT * FROM (SELECT DISTINCT nev FROM szeret), (SELECT gyumolcs FROM szeret WHERE nev = 'Micimack�')));

-- F�ggv�nyek
-- DOLGOZO, FIZ_KATEGORIA t�bla feladatok
SELECT * FROM dolgozo;
SELECT * FROM fiz_kategoria;
-- Kik azok a dolgoz�k, akik 1982.01.01 ut�n l�ptek be a c�ghez?
SELECT * FROM dolgozo WHERE belepes > TO_DATE('1982.01.01', 'YYYY.MM.DD');
-- Adjuk meg azon dolgoz�kat, akik nev�nek m�sodik bet�je A.
-- 2 megold�s:
SELECT * FROM dolgozo WHERE dnev LIKE '_A%';
SELECT * FROM dolgozo WHERE INSTR(dnev, 'A', 2, 1) = 2;
-- Adjuk meg azon dolgoz�kat, akik nev�ben van legal�bb k�t L bet�.
-- 2 megold�s:
SELECT * FROM dolgozo WHERE dnev LIKE '%L%L%';
SELECT * FROM dolgozo WHERE INSTR(dnev, 'L', 1, 2) > 0;
-- Adjuk meg a dolgoz�k nev�nek utols� h�rom bet�j�t.
SELECT SUBSTR(dnev, -3, 3), dolgozo.* FROM dolgozo;
-- Adjuk meg a dolgoz�k fizet�seinek n�gyzetgy�k�t k�t tizedesre, �s ennek eg�szr�sz�t.
SELECT ROUND(SQRT(fizetes), 2), FLOOR(ROUND(SQRT(fizetes), 2)), dolgozo.* FROM dolgozo;
-- Adjuk meg, hogy h�ny napja dolgozik a c�gn�l ADAMS �s milyen h�napban l�pett be.
SELECT (SYSDATE - belepes), TO_CHAR(belepes, 'month'), dolgozo.* FROM dolgozo WHERE dnev = 'ADAMS';
-- Adjuk meg azokat a (n�v, f�n�k) p�rokat, ahol a k�t ember neve ugyanannyi bet�b�l �ll.
SELECT d1.dnev, d2.dnev FROM dolgozo d1 JOIN dolgozo d2 ON d1.fonoke = d2.dkod WHERE LENGTH(d1.dnev) = LENGTH(d2.dnev);
-- List�zzuk ki a dolgoz�k nev�t �s fizet�s�t, valamint jelen�ts�k meg a fizet�st grafikusan �gy,
-- hogy a fizet�st 1000 Ft-ra kerek�tve, minden 1000 Ft-ot egy # jel jel�l.
SELECT dnev, fizetes, RPAD(' ', (fizetes/1000)+1, '#') FROM dolgozo;
-- List�zzuk ki azoknak a dolgoz�knak a nev�t, fizet�s�t, jutal�k�t, �s a jutal�k/fizet�s ar�ny�t,
-- akiknek a foglalkoz�sa elad� (salesman). Az ar�nyt k�t tizedesen jelen�ts�k meg.
SELECT dnev, fizetes, jutalek, ROUND(jutalek/fizetes, 2) FROM dolgozo WHERE LOWER(foglalkozas) = 'salesman';

-- Csoportk�pz�s

-- Adjuk meg mennyi a dolgoz�k k�z�tt el�fordul� maxim�lis fizet�s.
SELECT MAX(fizetes) FROM dolgozo;
-- Adjuk meg mennyi a dolgoz�k k�z�tt el�fordul� minim�lis fizet�s.
SELECT MIN(fizetes) FROM dolgozo;
-- Adjuk meg mennyi a dolgoz�k k�z�tt el�fordul� �tlagfizet�s.
SELECT AVG(fizetes) FROM dolgozo;
-- Adjuk meg a dolgoz� t�bla sorainak sz�m�t.
SELECT COUNT(*) FROM dolgozo;
-- Adjuk meg h�nyan dolgoznak az egyes oszt�lyokon.
SELECT oazon, COUNT(*) FROM dolgozo GROUP BY oazon ORDER BY oazon;
-- Adjuk meg azokra az oszt�lyokra az �tlagfizet�st, ahol ez nagyobb mint 2000.
SELECT oazon, AVG(fizetes) FROM dolgozo
    GROUP BY oazon
    HAVING AVG(fizetes) > 2000
    ORDER BY oazon;
-- Adjuk meg az �tlagfizet�st azokon az oszt�lyokon, ahol legal�bb 4-en dolgoznak (oazon, avg_fiz)
SELECT oazon, AVG(fizetes) FROM dolgozo
    GROUP BY oazon
    HAVING count(*) >= 3
    ORDER BY oazon;
-- Adjuk meg az �tlagfizet�st �s telephelyet azokon az oszt�lyokon, ahol legal�bb 4-en dolgoznak.
SELECT oazon, telephely, AVG(fizetes) FROM (dolgozo NATURAL JOIN osztaly)
    GROUP BY oazon, telephely
    HAVING count(*) >= 4;
-- Adjuk meg azon oszt�lyok nev�t �s telephely�t, ahol az �tlagfizet�s nagyobb mint 2000. (onev, telephely)
SELECT onev, telephely
    FROM dolgozo NATURAL JOIN osztaly
    GROUP BY onev, telephely
    HAVING AVG(fizetes) > 2000;
-- Adjuk meg azokat a fizet�si kateg�ri�kat, amelybe pontosan 3 dolgoz� fizet�se esik.
-- �j k�dol�si st�lust haszn�lok mostant�l
SELECT kategoria
FROM (dolgozo JOIN fiz_kategoria ON dolgozo.fizetes BETWEEN fiz_kategoria.also AND fiz_kategoria.felso)
GROUP BY kategoria
HAVING count(*) = 3
ORDER BY kategoria;
-- Adjuk meg azokat a fizet�si kateg�ri�kat, amelyekbe es� dolgoz�k mindannyian ugyanazon az oszt�lyon dolgoznak.


-- Adjuk meg azon oszt�lyok nev�t �s telephely�t, amelyeknek van 1-es fizet�si kateg�ri�j� dolgoz�ja.

-- Adjuk meg azon oszt�lyok nev�t �s telephely�t, amelyeknek legal�bb 2 f� 1-es fiz. kateg�ri�j� dolgoz�ja van.

-- K�sz�ts�nk list�t a p�ros �s p�ratlan azonos�t�j� (dkod) dolgoz�k sz�m�r�l.

-- List�zzuk ki munkak�r�nk�nt a dolgoz�k sz�m�t, �tlagfizet�s�t (kerek�tve) numerikusan �s grafikusan is. 200-ank�nt jelen�ts�nk meg egy #-ot
