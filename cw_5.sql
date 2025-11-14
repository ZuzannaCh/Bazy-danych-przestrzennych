CREATE EXTENSION postgis;

--Zadanie 1---
CREATE TABLE obiekty (
	nazwa VARCHAR(255),
	geom GEOMETRY
);

--a
INSERT INTO obiekty VALUES
('obiekt1', (ST_GeomFromText('COMPOUNDCURVE(
	(0 1, 1 1),
	CIRCULARSTRING(1 1, 2 0, 3 1),
	CIRCULARSTRING(3 1, 4 2, 5 1),
	(5 1, 6 1))',0)));
--b
--wersja: poligon
INSERT INTO obiekty VALUES
('obiekt2', ST_GeomFromText('CURVEPOLYGON(
		COMPOUNDCURVE(
					(10 6, 14 6),
					CIRCULARSTRING(14 6, 16 4, 14 2),
					CIRCULARSTRING(14 2, 12 0, 10 2),
					(10 2, 10 6)), 		
		CIRCULARSTRING(11 2, 13 2, 11 2)
		)',0));
			
--wersja: dwie linie
INSERT INTO obiekty VALUES
('obiekt2a', ST_GeomFromText('MULTICURVE(
		COMPOUNDCURVE(
					(10 6, 14 6),
					CIRCULARSTRING(14 6, 16 4, 14 2),
					CIRCULARSTRING(14 2, 12 0, 10 2),
					(10 2, 10 6)), 		
		CIRCULARSTRING(11 2, 13 2, 11 2)
		)',0));

--c
INSERT INTO obiekty VALUES
('obiekt3', ST_GeomFromText('POLYGON((10 17, 12 13, 7 15, 10 17))',0));
--d
INSERT INTO obiekty VALUES
('obiekt4', ST_GeomFromText('LINESTRING(20 20, 25 25, 27 24, 26 22, 26 21, 22 19, 20.5 19.5)',0));
--e
INSERT INTO obiekty VALUES
('obiekt5', ST_GeomFromText('MULTIPOINT( (30 30 59), (38 32 234))',0));
--f
INSERT INTO obiekty VALUES
('obiekt6', ST_GeomFromText(
	'GEOMETRYCOLLECTION(
		LINESTRING(1 1, 3 2),
		POINT(4 2)
	)',
0));

/* do wyświetlanie i sprawdzania, czy dobrze wpisane - ST_CurveToLine, 
aby wyświetlać w geometry viewer*/
SELECT nazwa, ST_CurveToLine(geom) FROM obiekty

--Zadanie 2--
SELECT ST_Area(
		ST_Buffer(
			ST_ShortestLine(
				(SELECT geom FROM obiekty WHERE nazwa='obiekt3'),
				(SELECT geom FROM obiekty WHERE nazwa='obiekt4')
			),5));

--zadanie 3--
/*aby utworzyć poligon linie muszą być zamknięte, dlatego dodajemy punkt do poligonu
używamy AddPoint do tego, a wewnątrz StartPoint, aby dodać na końcu pierwszy punkt*/
UPDATE obiekty
SET geom = ST_MakePolygon(
				ST_AddPoint(
					geom, ST_StartPoint(geom)))
WHERE nazwa = 'obiekt4'

--zadanie 4--
--łączymy dwa obiekty w kolekcję
INSERT INTO obiekty VALUES
('obiekt7', ST_Collect(
				(SELECT geom FROM obiekty WHERE nazwa='obiekt3'),
				(SELECT geom FROM obiekty WHERE nazwa='obiekt4')
));
--do sprawdzenia jak wygląda obiekt7
SELECT nazwa, ST_CurveToLine(geom) FROM obiekty WHERE nazwa='obiekt7';

--zadanie 5--
SELECT SUM(ST_Area(ST_Buffer(geom,5)))
FROM obiekty
WHERE ST_HasArc(geom) = FALSE;