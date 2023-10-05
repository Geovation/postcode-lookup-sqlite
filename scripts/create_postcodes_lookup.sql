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
   code text,
   name text
);

create table staging_districts (
   code text primary key,
   name text,
   welsh_name text
) without rowid;

create table districts (
   code text,
   name text
);

create table staging_countries (
   code text primary key,
   code_2 text,
   name text,
   welsh_name text
) without rowid;

create table countries (
   code text,
   name text
);

create table staging_regions (
   code text primary key,
   code_2 text,
   name text,
   welsh_name text
) without rowid;

create table regions (
   code text,
   name text
);

create table staging_constituencies (
   code text primary key,
   name text
) without rowid;

create table constituencies (
   code text,
   name text
);

create table postcodes (
   postcode text primary key,
   county_id integer,
   district_id integer,
   country_id integer,
   region_id integer,
   constituency_id integer,
   foreign key (county_id) references counties(rowid),
   foreign key (district_id) references districts(rowid),
   foreign key (country_id) references countries(rowid),
   foreign key (region_id) references regions(rowid),
   foreign key (constituency_id) references constituencies(rowid)
) without rowid;

create view vw_postcodes as
select
   p.postcode,
   c.name as county_name, 
   c.code as county_code, 
   d.name as district_name,
   d.code as district_code,
   co.name as country_name,
   co.code as country_code,
   r.name as region_name,
   r.code as region_code,
   con.name as constituency_name,
   con.code as constituency_name
from postcodes p
left join counties c on p.county_id = c.rowid
left join districts d on p.district_id = d.rowid
left join countries co on p.country_id = co.rowid
left join regions r on p.region_id = r.rowid
left join constituencies con on p.constituency_id = con.rowid;

.separator ,
.import "data/postcodes.csv" staging_postcodes
.import "data/counties.csv" staging_counties
.import "data/districts.csv" staging_districts
.import "data/countries.csv" staging_countries
.import "data/regions.csv" staging_regions
.import "data/constituencies.csv" staging_constituencies

insert into counties (code, name)
select distinct code, name from staging_counties;
drop table staging_counties;

insert into districts (code, name)
select distinct code, name from staging_districts;
drop table staging_districts;

insert into countries (code, name)
select distinct code, name from staging_countries;
drop table staging_countries;

insert into regions (code, name)
select distinct code, name from staging_regions;
drop table staging_regions;

insert into constituencies (code, name)
select distinct code, name from staging_constituencies;
drop table staging_constituencies;

insert into postcodes(postcode, county_id, district_id, country_id, region_id, constituency_id)
select p.postcode, c.rowid, d.rowid, co.rowid, r.rowid, con.rowid
from staging_postcodes p
left join counties c on p.county = c.code
left join districts d on p.district = d.code
left join countries co on p.country = co.code
left join regions r on p.region = r.code
left join constituencies con on p.constituency = con.code;

drop table staging_postcodes;

vacuum;
