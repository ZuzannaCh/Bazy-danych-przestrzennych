CREATE EXTENSION postgis;

CREATE TABLE buildings (
	id SERIAL PRIMARY KEY,
	name_ VARCHAR(255),
	geometry GEOMETRY(POLYGON)
);

CREATE TABLE roads (
	id SERIAL PRIMARY KEY,
	name_ VARCHAR(255),
	geometry GEOMETRY(LINESTRING)
);

CREATE TABLE poi (
	id SERIAL PRIMARY KEY,
	name_ VARCHAR(255),
	geometry GEOMETRY(POINT)
);

INSERT INTO buildings(name_, geometry) VALUES
	('BuildingA', ST_GeomFromText('POLYGON((8 4, 8 1.5, 10.5 1.5, 10.5 4, 8 4))')),
	('BuildingB', ST_GeomFromText('POLYGON((4 7, 4 5, 6 5, 6 7, 4 7))')),
	('BuildingC', ST_GeomFromText('POLYGON((3 8, 3 6, 5 6, 5 8, 3 8))')),
	('BuildingD', ST_GeomFromText('POLYGON((9 9, 9 8, 10 8, 10 9, 9 9))')),
	('BuildingE', ST_GeomFromText('POLYGON((1 2, 1 1, 2 1, 2 2, 1 2))'));

INSERT INTO roads (name_, geometry) VALUES
	('RoadX', ST_GeomFromText('LINESTRING(0 4.5, 12 4.5)')),
	('RoadY', ST_GeomFromText('LINESTRING(7.5 0, 7.5 10.5)'));

INSERT INTO poi (name_, geometry) VALUES
	('G', ST_GeomFromText('POINT(1 3.5)')),
	('H', ST_GeomFromText('POINT(5.5 1.5)')),
	('I', ST_GeomFromText('POINT(9.5 6)')),
	('J', ST_GeomFromText('POINT(6.5 6)')),
	('K', ST_GeomFromText('POINT(6 9.5)'));


--zadanie 6--
--a--
SELECT SUM(ST_Length(geometry)) as "dlugosc drog"
FROM roads;

--b--
SELECT ST_AsText(geometry) as wkt, ST_Area(geometry) as pole, ST_Perimeter(geometry) as obwod
FROM buildings
WHERE name_ LIKE 'BuildingA';

--c--
SELECT name_ as nazwa, ST_Area(geometry) as pole
FROM buildings
ORDER BY name_;

--d--
SELECT name_ as nazwa, ST_Perimeter(geometry) as obwod
FROM buildings
ORDER BY ST_Area(geometry) DESC
LIMIT 2;

--e--
SELECT ST_Distance(b.geometry, p.geometry) as odleglosc
FROM buildings b, poi p
WHERE b.name_ = 'BuildingC' AND p.name_ ='K';

--f--
SELECT ST_Area(ST_DIfference(c.geometry, ST_Buffer(b.geometry, 0.5))) as pole
FROM buildings c, buildings b
WHERE c.name_='BuildingC' AND b.name_='BuildingB';

--g--
SELECT b.name_
FROM buildings b, roads r
WHERE r.name_='RoadX'
	AND ST_Y(ST_Centroid(b.geometry))>ST_Y(ST_Centroid(r.geometry));

--h--
SELECT ST_Area(ST_SymDifference(c.geometry, ST_GeomFromtext('POLYGON((4 7, 6 7, 6 8, 4 8, 4 7))'))) as pole
FROM buildings c
WHERE c.name_ LIKE '%C';
