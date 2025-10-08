-- 1 --
CREATE DATABASE firma;

-- 2 --
CREATE SCHEMA ksiegowosc;

--3--

CREATE TABLE ksiegowosc.pracownicy (
	id_pracownika SERIAL NOT NULL PRIMARY KEY,
	imie VARCHAR(50) NOT NULL,
	nazwisko VARCHAR(50) NOT NULL,
	adres VARCHAR(200),
	telefon CHAR(9)
);
COMMENT ON TABLE ksiegowosc.pracownicy IS 'Pracownicy';

CREATE TABLE ksiegowosc.godziny (
	id_godziny SERIAL NOT NULL PRIMARY KEY,
	data_ DATE NOT NULL,
	liczba_godzin INT CHECK (liczba_godzin>=0),
	id_pracownika INT NOT NULL REFERENCES ksiegowosc.pracownicy(id_pracownika)
);
COMMENT ON TABLE ksiegowosc.godziny IS 'Godziny pracy';

CREATE TABLE ksiegowosc.pensja (
	id_pensji SERIAL NOT NULL PRIMARY KEY,
	stanowisko VARCHAR(100) NOT NULL,
	kwota NUMERIC (10,2) CHECK (kwota>0)
);
COMMENT ON TABLE ksiegowosc.pensja IS 'Podstawowa pensja';

CREATE TABLE ksiegowosc.premia (
	id_premii SERIAL NOT NULL PRIMARY KEY,
	rodzaj VARCHAR(100),
	kwota NUMERIC (10,2) CHECK (kwota>=0)
);
COMMENT ON TABLE ksiegowosc.premia IS 'Premia';

CREATE TABLE ksiegowosc.wynagrodzenie (
    id_wynagrodzenia SERIAL NOT NULL PRIMARY KEY,
    data_ DATE,
    id_pracownika INT NOT NULL REFERENCES ksiegowosc.pracownicy(id_pracownika) ON DELETE CASCADE,
    id_godziny INT REFERENCES ksiegowosc.godziny(id_godziny) ON DELETE SET NULL,
    id_pensji INT REFERENCES ksiegowosc.pensja(id_pensji) ON DELETE SET NULL,
    id_premii INT REFERENCES ksiegowosc.premia(id_premii) ON DELETE SET NULL
);
COMMENT ON TABLE ksiegowosc.wynagrodzenie IS 'Wyliczone wynagrodzenie';


-- 4--
INSERT INTO ksiegowosc.pracownicy (imie, nazwisko, adres, telefon) VALUES 
('Jan', 'Kowalski', 'Gdynia', '123456789'),
('Jakub', 'Nowak', 'Krakow', '487382356'),
('Aleksandra', 'Burak', 'Warszawa', '487381156'),
('Amelia', 'Kwiat', 'Wroclaw', '997382356'),
('Konstancja', 'Lilia', 'Poznan', '487382444'),
('Florian', 'Malina', 'Torun', '487399356'),
('Kacper', 'Drabinka', 'Bydgoszcz', '485552356'),
('Zofia', 'Potocka', 'Bialystok', '487333336'),
('Anastazja', 'Nowa', 'Zielona Gora', '487388886'),
('Damian', 'Kalisz', 'Kalisz', '483332356');

INSERT INTO ksiegowosc.godziny (data_, liczba_godzin, id_pracownika) VALUES
('2025-10-01', 160, 1),
('2025-10-01', 150, 2),
('2025-10-01', 13, 1),
('2025-10-01', 120, 4),
('2025-10-01', 80, 5),
('2025-10-01', 160, 6),
('2025-10-01', 170, 7),
('2025-10-01', 140, 8),
('2025-10-01', 120, 9),
('2025-10-01', 147, 10);



INSERT INTO ksiegowosc.pensja (stanowisko, kwota) VALUES
('kierownik', 8000.00),
('project manager', 7500.00),
('data analist', 7000.00),
('ksiegowy', 5600.00),
('mlodszy ksiegowy', 4800.00),
('pracownik administracyjny', 4000.00),
('kadrowy', 5800.00),
('stazysta', 5000.00),
('junior', 6500.00),
('senior', 8000.00);


INSERT INTO ksiegowosc.premia (rodzaj, kwota) VALUES
('Premia prowizyjna', 800.00),
('Premia roczna', 1500.00),
('Premia świąteczna', 1000.00),
('Premia kwartalna', 1200.00),
('Premia zadaniowa', 500.00),
('Premia motywacyjna', 900.00),
('Premia projektowa', 1100.00),
('Premia frekwencyjna', 1300.00),
('Premia specjalna', 2000.00),
('Premia uznaniowa', 2500.00);

INSERT INTO ksiegowosc.wynagrodzenie (data_, id_pracownika, id_godziny, id_pensji, id_premii) VALUES
('2025-10-02', 1, 1, 1, 1),
('2025-10-02', 2, 2, 1, 3),
('2025-10-02', 3, 3, 3, 2),
('2025-10-02', 4, 4, 4, 5),
('2025-10-02', 5, 5, 5, 4),
('2025-10-02', 6, 6, 6, 6),
('2025-10-02', 7, 7, 7, 7),
('2025-10-02', 8, 8, 8, 8),
('2025-10-02', 9, 9, 9, 9),
('2025-10-02', 10, 10, 10, 10);

-- 5 --

--a--
SELECT id_pracownika, nazwisko FROM ksiegowosc.pracownicy;

--b--
SELECT w.id_pracownika, p.kwota
FROM ksiegowosc.wynagrodzenie w
JOIN ksiegowosc.pensja p ON w.id_pensji=p.id_pensji
WHERE p.kwota > 7000;

--c--
UPDATE ksiegowosc.wynagrodzenie
SET id_premii = NULL
WHERE id_pracownika=9; --aby jakiś wynik byl

SELECT w.id_pracownika, p.kwota
FROM ksiegowosc.wynagrodzenie w
JOIN ksiegowosc.pensja p ON p.id_pensji=w.id_pensji
WHERE id_premii is NULL AND p.kwota > 2000;

--d--
SELECT * FROM ksiegowosc.pracownicy
WHERE imie LIKE 'J%';

--e--
SELECT * FROM ksiegowosc.pracownicy
WHERE nazwisko LIKE '%n%a';

--f--
SELECT p.imie, p.nazwisko, GREATEST(SUM(g.liczba_godzin)-160, 0) as nadgodziny
FROM ksiegowosc.pracownicy p
JOIN ksiegowosc.godziny g ON p.id_pracownika=g.id_pracownika
GROUP BY p.id_pracownika, p.imie, p.nazwisko;

--g--
SELECT p.imie, p.nazwisko, pe.kwota
FROM ksiegowosc.pracownicy p
JOIN ksiegowosc.wynagrodzenie w ON w.id_pracownika=p.id_pracownika
JOIN ksiegowosc.pensja pe ON w.id_pensji=pe.id_pensji
WHERE pe.kwota BETWEEN 4500 AND 6000;

--h--
SELECT p.imie, p.nazwisko,  SUM(g.liczba_godzin) AS przepracowane_godziny, w.id_premii
FROM ksiegowosc.pracownicy p
JOIN ksiegowosc.wynagrodzenie w ON w.id_pracownika=p.id_pracownika
JOIN ksiegowosc.godziny g ON g.id_pracownika=p.id_pracownika
WHERE w.id_premii=7 --w zadaniu: is NULL
GROUP BY p.id_pracownika, p.imie, p.nazwisko, w.id_premii
HAVING (SUM(g.liczba_godzin)-160)>0;

--i--
SELECT p.id_pracownika, p.imie, p.nazwisko, pe.kwota
FROM ksiegowosc.pracownicy p 
JOIN ksiegowosc.wynagrodzenie w ON w.id_pracownika=p.id_pracownika
JOIN ksiegowosc.pensja pe ON pe.id_pensji=w.id_pensji
ORDER BY pe.kwota;

--j--
SELECT p.id_pracownika, p.imie, p.nazwisko, pe.kwota, pr.kwota
FROM ksiegowosc.pracownicy p 
JOIN ksiegowosc.wynagrodzenie w ON w.id_pracownika=p.id_pracownika
JOIN ksiegowosc.pensja pe ON pe.id_pensji=w.id_pensji
JOIN ksiegowosc.premia pr ON pr.id_premii=w.id_premii
ORDER BY pe.kwota desc, pr.kwota desc;

--k--
SELECT pe.stanowisko, COUNT(DISTINCT p.id_pracownika) AS liczba_pracownikow
FROM ksiegowosc.pracownicy p
JOIN ksiegowosc.wynagrodzenie w ON p.id_pracownika = w.id_pracownika
JOIN ksiegowosc.pensja pe ON w.id_pensji = pe.id_pensji
GROUP BY pe.stanowisko;

--l--
SELECT stanowisko, ROUND(AVG(kwota), 2) AS srednia_placa, 
	MIN(kwota) AS minimalna_placa, MAX(kwota) AS maksymalna_placa
FROM ksiegowosc.pensja
WHERE stanowisko = 'kierownik'
GROUP BY stanowisko;

--m--
SELECT SUM(pe.kwota + COALESCE(pr.kwota, 0)) AS suma_wynagrodzen
FROM ksiegowosc.wynagrodzenie w
JOIN ksiegowosc.pensja pe ON w.id_pensji = pe.id_pensji
LEFT JOIN ksiegowosc.premia pr ON w.id_premii = pr.id_premii;

--n--
SELECT pe.stanowisko, SUM(pe.kwota + COALESCE(pr.kwota, 0)) AS suma_wynagrodzen
FROM ksiegowosc.wynagrodzenie w
JOIN ksiegowosc.pensja pe ON w.id_pensji = pe.id_pensji
LEFT JOIN ksiegowosc.premia pr ON w.id_premii = pr.id_premii
GROUP BY pe.stanowisko
ORDER BY suma_wynagrodzen;

--o--
SELECT pe.stanowisko, COUNT(w.id_premii) AS liczba_premii
FROM ksiegowosc.wynagrodzenie w
JOIN ksiegowosc.pensja pe ON w.id_pensji = pe.id_pensji
GROUP BY pe.stanowisko
ORDER BY liczba_premii;

--p--
DELETE FROM ksiegowosc.pracownicy p
WHERE p.id_pracownika IN (
						SELECT w.id_pracownika
						FROM ksiegowosc.wynagrodzenie w
						JOIN ksiegowosc.pensja pe ON pe.id_pensji=w.id_pensji
						WHERE pe.kwota<1200
						);