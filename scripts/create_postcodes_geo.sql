.load /usr/local/lib/mod_spatialite.dylib
select initspatialmetadata('WGS84_ONLY');

PRAGMA trusted_schema=1;

create table staging_postcodes (
   postcode text,
   county text,
   district text,
   country text,
   region text,
   constituency text,
   latitude real,
   longitude real
);

create table postcodes (
   postcode text primary key
);

select addgeometrycolumn('postcodes', 'geom', 4326, 'POINT', 'XY');

.separator ,
.import "data/postcodes.csv" staging_postcodes

insert into postcodes(postcode, geom)
select p.postcode, makepoint(p.longitude, p.latitude, 4326)
from staging_postcodes p
where region = :regionid;

select createspatialindex('postcodes', 'geom');

drop table staging_postcodes;

vacuum;
