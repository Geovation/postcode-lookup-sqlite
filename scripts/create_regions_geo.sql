.load /usr/local/lib/mod_spatialite.dylib
select initspatialmetadata('WGS84_ONLY');

PRAGMA trusted_schema=1;

create table regions (
  code text,
  name text
);

select addgeometrycolumn('regions', 'geom', 4326, 'MULTIPOLYGON', 'XY');

insert into regions(code, name, geom)
select 
   json_extract(value, '$.properties.code') as code,
   json_extract(value, '$.properties.name') as name,
   GeomFromText(AsText(GeomFromGeoJson(
      json_object('type',json_extract(value,'$.geometry.type'),'coordinates',json_extract(value,'$.geometry.coordinates')))
   ),4326) as geom
from json_each(readfile('data/regions.geojson'), '$.features');

vacuum;
