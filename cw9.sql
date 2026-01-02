CREATE EXTENSION postgis;
CREATE EXTENSION postgis_raster;

SELECT * FROM exports;

CREATE TABLE wynik AS
SELECT ST_UNION(rast)
FROM exports;

