create table staging_postcodes (
   postcode text primary key,
   county text,
   district text,
   country text,
   region text,
   constituency text,
   latitude real,
   longitude real
) without rowid;

create table staging_counties (
   code text primary key,
   name text,
   blank_1 text,
   blank_2 text
) without rowid;

create table counties (
   name text
);

create table staging_districts (
   code text primary key,
   name text,
   welsh_name text
) without rowid;

create table districts (
   name text
);

create table staging_countries (
   code text primary key,
   code_2 text,
   name text,
   welsh_name text
) without rowid;

create table countries (
   name text
);

create table staging_regions (
   code text primary key,
   code_2 text,
   name text,
   welsh_name text
) without rowid;

create table regions (
   name text
);

create table staging_constituencies (
   code text primary key,
   name text,
   welsh_name text
) without rowid;

create table constituencies (
   code text primary key,
   name text
);

create table postcodes (
   postcode text primary key,
   county_id integer,
   district_id integer,
   country_id integer,
   region_id integer,
   constituency_id integer,
   latitude real,
   longitude real,
   foreign key (county_id) references counties(rowid),
   foreign key (district_id) references districts(rowid),
   foreign key (country_id) references countries(rowid),
   foreign key (region_id) references regions(rowid),
   foreign key (constituency_id) references constituencies(rowid)
) without rowid;

.separator ,
.import "database/postcodes.csv" staging_postcodes
.import "database/counties.csv" staging_counties
.import "database/districts.csv" staging_districts
.import "database/countries.csv" staging_countries
.import "database/regions.csv" staging_regions
.import "database/constituencies.csv" staging_constituencies


drop table staging_postcodes;

vacuum;
