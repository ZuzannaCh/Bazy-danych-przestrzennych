CREATE EXTENSION postgis;

--1--
SELECT *
FROM t2019_kar_buildings;
SELECT *
FROM t2018_kar_buildings;

SELECT b19.*, b18.polygon_id as old_id, b18.geom as old_geom
INTO nowe_budynki
FROM t2019_kar_buildings b19
LEFT JOIN t2018_kar_buildings b18 ON b19.polygon_id=b18.polygon_id
WHERE b18.polygon_id IS NULL
	OR NOT ST_Equals(b19.geom, b18.geom);

--2--
CREATE TABLE nowe_poi AS
SELECT p19.* 
FROM t2019_kar_poi_table p19
LEFT JOIN t2018_kar_poi_table p18 ON p18.poi_id=p19.poi_id
WHERE p18.poi_id IS NULL;

SELECT * FROM nowe_poi

SELECT  np.type, COUNT(DISTINCT np.poi_id) as l_poi
FROM  nowe_poi np
JOIN nowe_budynki nb ON ST_DWithin(ST_transform(np.geom, 3068), ST_transform(nb.geom, 3068), 500)
GROUP BY np.type;

--3--
CREATE TABLE streets_reprojected AS
SELECT *, ST_Transform(geom, 3068) as geom_new
FROM t2019_kar_streets;

ALTER TABLE streets_reprojected
DROP COLUMN geom ;

SELECT * FROM streets_reprojected;

--4--
CREATE TABLE input_points (
id SERIAL PRIMARY KEY,
geom GEOMETRY(POINT));

INSERT INTO input_points(geom) VALUES
	(ST_GeomFromText('POINT(8.36093 49.03174)', 4326)),
	(ST_GeomFromText('POINT(8.39876 49.00644)', 4326));
	
--5--
UPDATE input_points
SET geom = ST_Transform(geom, 3068);

--6--
SELECT sn.*
FROM t2019_kar_street_node sn
WHERE ST_DWithin(
	ST_Transform(sn.geom,3068), (
	SELECT ST_MakeLine(a.geom, b.geom)
	FROM input_points a, input_points b
	WHERE a.id=1 AND b.id=2),
	200);

--7--
SELECT * FROM t2019_kar_poi_table WHERE type='Sporting Goods Store';
SELECT * FROM t2019_kar_land_use_a WHERE type='Park (City/County)';

SELECT COUNT(DISTINCT p.poi_id)
FROM t2019_kar_poi_table p
JOIN t2019_kar_land_use_a lu ON ST_DWithin(
	ST_Transform(p.geom, 3068),
	ST_Transform(lu.geom, 3068),
	300)
WHERE p.type='Sporting Goods Store' 
	AND lu.type='Park (City/County)';

--8--
CREATE TABLE t2019_kar_bridges AS
SELECT (ST_Intersection(r.geom, w.geom))
FROM t2019_kar_railways r, t2019_kar_water_lines w;

SELECT * FROM t2019_kar_bridges
