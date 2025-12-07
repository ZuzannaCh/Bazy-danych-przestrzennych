CREATE EXTENSION postgis;
CREATE EXTENSION postgis_raster;

CREATE SCHEMA rastry;

--Zadanie 1

/*Pobrano 1:250 000 Scale Colour Raster™ Free OS OpenData*/

--Zadanie 2

/* Załadowano za pomocą narzędzia raster2pgsql w Powershellu:
	1. cd do folderu z danymi
	2. $first = Get-ChildItem *.tif | Select-Object -First 1 
	      & "C:\Program Files\PostgreSQL\18\bin\raster2pgsql.exe" 
	      -s 27700 -I -M -d $first rastry.uk_250k1 | 
		  psql -d cw_8 -h localhost -U postgres
	3. $rest = Get-ChildItem *.tif | Select-Object -Skip 1
         foreach ($f in $rest) {
          & "C:\Program Files\PostgreSQL\18\bin\raster2pgsql.exe" -s 27700 -I -M -a $f rastry.uk_250k1 | psql -d cw_8 -h localhost -U postgres
           }*/
	
SELECT * FROM rastry.uk_250k1 LIMIT 5;

-- Zadanie 3 

/* połączenie danych za pomocą ST_Union:*/

-- CREATE TABLE rastry.union_uk250k AS
-- SELECT ST_UNION(rast)
-- FROM rastry.uk_250k1;

/*powyższe zapytanie wymaga zbyt pamięci, aby się wykonać.
Łatwiej było zrobić to przy użyciu GDAL:

	W OSGEO4Well:
	1. cd do folderu z danymi
	2. gdalbuildvrt mosaic.vrt *.tif
	3. gdal_translate mosaic.vrt uk_250k_mosaic.tif
*/

--ZADANIE 4

/*Pobrano dane OS Open Zoomstack w formacie Geopackage*/

--Zadanie 5

/*Do załadadowania do bazy danych tabeli z parkami narodowymi użyto ogr2ogr:

	ogr2ogr -f "PostgreSQL" "PG:host=localhost dbname=cw_8 user=postgres password=***" 
	OS_Open_Zoomstack.gpkg -nln national_parks national_parks */

--Zadanie 6 - przycięcie danych z 1. do Lake District

CREATE TABLE rastry.uk_lake_district AS
SELECT ST_Union (ST_Clip(a.rast, b.geom, true)) AS rast
FROM rastry.uk_250k1 AS a, national_parks AS b
WHERE ST_Intersects(a.rast, b.geom) AND b.id=40;

SELECT AddRasterConstraints('rastry'::name, 'uk_lake_district'::name,'rast'::name);

--Zadanie 7 - eksport

/* Wykonane w GDAL:
   1. otworzyć OSGeo4W Shell
   2. E: (przejść do folderu - np pendrive)
   3. gdal_translate -co COMPRESS=DEFLATE -co PREDICTOR=2 -co ZLEVEL=9 
       PG:"host=localhost port=5432 dbname=cw_8 user=postgres password=*** 
	   schema=rastry table=lake_district mode=2" lake_district.tiff
*/

--Zadanie 8

/*Pobrano dane z Sentinela 2 ze strony https://browser.dataspace.copernicus.eu/ */

--Zadanie 9

/*Do bazy załadowano rastry zawierające pasma 03 i 08:
   1. cd do folderu z zobrazowaniami 10m z Sentinela
   2. "C:\Program Files\PostgreSQL\18\bin\raster2pgsql.exe" -I -C -M -d 
   		"T30UVF_20250513T112131_B08_10m.jp2" rastry.sentinel_08 | 
		psql -d cw_8 -h localhost -U postgres */
		

--Zadanie 10 - wskaźnik NDWI i przycięcie do Lake District

CREATE TABLE rastry.sentinel_ndwi AS
SELECT
	r1.rid,ST_MapAlgebra(
	r1.rast,
	r2.rast,
	'CASE 
          WHEN ([rast1.val] + [rast2.val]) = 0 THEN NULL
          ELSE ([rast1.val] - [rast2.val]) / ([rast1.val] + [rast2.val])::float
     END',
     '32BF'
) AS rast
FROM rastry.sentinel_03 AS r1, rastry.sentinel_08 AS r2;


CREATE TABLE rastry.ndwi_lake_district AS
SELECT ST_Clip(ST_Transform(a.rast, 27700), b.geom, true) AS rast
FROM rastry.sentinel_ndwi AS a, national_parks AS b
WHERE ST_Intersects(ST_Transform(a.rast, 27700), b.geom) AND b.id=40;


--Zadanie 11 - eksport

/*gdal_translate -co COMPRESS=DEFLATE -co PREDICTOR=2 -co ZLEVEL=9    
  PG:"host=localhost port=5432 dbname=cw_8 user=postgres password=***  
  schema=rastry table=ndwi_lake_district mode=2" ndwi_lake_district.tiff */