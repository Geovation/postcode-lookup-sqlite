# Postcode lookup - SQLite and Spatialite

This is a project to output a set of small SQLite databases to support embedded postcode lookup capabilities, and provide postcode-associated geographies. These are built with data from the ONS Postcode directory. They are small and portable SQLite/Spatialite databases that can be embedded into multiple code solutions.

## Database specification

This solution produces three databases in the `database` directory.

1. A spatialite region database. This requires spatialite extensions to be installed, or for you to use the command-line version of spatialite. It will provide a region name from location co-ordinates. This can then be used to query the correct postcode geo-lookup database.
2. A spatialite postcode database. This also requires spatialite to find a postcode from a location (reverse geocode). This is available as a single file (too large to be included in this repo), or as individual files per UK region. The UK region files are quicker but require a region to be identified first.
3. A postcode lookup database as a plain SQLite file. This provides lookup geographies for a postcode such as the county, district and wetsminster constituency.

Despite sometimes requiring multiple code lines to query each database, they should all be performant and provide local and powerful geocoding capabilities without requiring either API calls or remote database calls.

## Updating files guide

The databases are built from files published in the [ONS Postcode Directory Lookup](<https://geoportal.statistics.gov.uk/search?collection=Dataset&sort=-created&tags=all(PRD_ONSPD)>). Postcodes and admin geographies change, so a new version is published every quarter. These are instructions to prepare a new set of files that can then be used to generate a fresh set of database files.

1. Download the [latest ONS Postcode Directory Lookup](<https://geoportal.statistics.gov.uk/search?collection=Dataset&sort=-created&tags=all(PRD_ONSPD)>). This will be provided in a zip file.
2. Extract the main file into the data directory. It will be called something like `ONSPD_AUG_2023_UK.csv`. The file can change format, so these scripts will need to be maintained to work with the latest version.
3. Also extract the following files, which should be in the `documents` directory of the download. Copy these to the data directory.

```
Country names and codes UK as at 08_12.csv,County names and codes UK as at 04_21.csv,LA_UA names and codes UK as at 04_23.csv,Region names and codes EN as at 12_20 (RGN).csv,Westminster Parliamentary Constituency names and codes UK as at 12_14.csv
```

3. At a Linux based console, within this root directory, run the following.

```console
./process_files.sh
```

This extracts data for the following fields (field position in brackets):

- PCD(1): Unit postcode – 7 character version
- OSCTY(6): County
- OSLAUA(8): Local authority district (LAD)/unitary authority (UA)/ metropolitan district (MD)/ London borough (LB)/ council area (CA)/district council area (DCA)
- CTRY(17): Country
- RGN(18): Region
- PCON(20): Westminster parliamentary constituency
- LAT(43): Decimal degrees latitude
- LONG(44): Decimal degrees longitude

This will process the ONS postcode directory into a smaller file called `postcodes.csv`. It will also process the supporting files to rename them into a lowercase standard file name such as `countries.csv`.

## Generate the region spatial database

Run the following to generate an indexed spatialite database for UK regions.

```console
./generate_region_geo_db.sh
```

This creates a `regions_geo.sqlite` file within the database directory. Currently this is around 5Mb. At that size it can be relatively easily embedded into projects, as well as included in GitHub repositories, without problem.

The database can be tested using a Spatialite command line, or SQLite with spatialite extensions enabled. For the following commands the brew installed sqlite3 is being used on MacOS, as it supports extensions. In most cases a standard SQLite path would work.

```console
/usr/local/Cellar/sqlite/3.43.1/bin/sqlite3 database/regions_geo.sqlite
.load /usr/local/lib/mod_spatialite.dylib
select code, name from regions where within(makepoint(-2.36, 51.38, 4326), geom);
```

This query should produce the following results.

| Code      | Region     |
| --------- | ---------- |
| E12000009 | South West |

## Generate the postcode spatial databases

Run the following to generate a set of indexed spatialite database for UK postcodes.

```console
./generate_postcode_geo_db.sh
```

This creates a set of 12 files within the database directory, such as `postcodes_geo_east_midlands.sqlite`. Each one is about 30Mb or so. At that size they should be able to be relatively easily embedded into projects, as well as deployed from GitHub repositories, without problem. A full file is also generated, called `postcodes_geo.sqlite`. This is about 264Mb. This is much more convenient as a lookup, but can be prohibitive for embedding into projects, depending on your requirements.

The database can be tested using a Spatialite command line, as previously:

```console
/usr/local/Cellar/sqlite/3.43.1/bin/sqlite3 database/postcodes_geo.sqlite
.load /usr/local/lib/mod_spatialite.dylib
select postcode from postcodes order by distance(makepoint(-2.36, 51.38, 4326), geom) limit 1;
```

This query should produce the following results.

| Postcode |
| -------- |
| BA1 1QF  |

For full postcode information the postcode lookup database can then be used (see below). The postcode can be directly passed into the postcode lookup database for best performance.

## Generate postcode lookup database

Run the following to generate an indexed SQLite database for postcode information.

```console
./generate_postcode_lookup_db.sh
```

This creates a `postcodes.sqlite` file within the database directory. Currently this is around 43Mb. At that size it can be relatively easily embedded into projects, as well as included in GitHub repositories.

The database can be tested using a plan SQLite command line. Data is accessed using the `vw_postcodes` view, which provides geography codes and names for postcodes.

```console
sqlite3 database/postcodes.sqlite "select * from vw_postcodes where postcode = 'BA1 1RG'"
```

This query should produce the following results.

| Postcode | County name                 | County code | District name                | District code | Country name | Country code | Region name | Region code | Contituency name | Constituency code |
| -------- | --------------------------- | ----------- | ---------------------------- | ------------- | ------------ | ------------ | ----------- | ----------- | ---------------- | ----------------- |
| BA1 1RG  | (pseudo) England (UA/MD/LB) | E99999999   | Bath and North East Somerset | E06000022     | England      | E92000001    | South West  | E12000009   | Bath             | E14000547         |

The postcode column is the primary clustered index, so should perform well when doing an exact match (i.e. with space). Other fields are not indexed so will not provide great performance.

## Sample code

A python code file is included to test the databases. This takes in two command line arguments for longitude and latitude, and it will print postcode information.

Setup (MacOS):

```console
brew install libspatialite
pip install spatialite
```

Setup (Linux):

```console
apt-get install libsqlite3-mod-spatialite
pip install spatialite
```

Run:

```console
python sample.py -2.36 51.38
```

This should produce the following printed output.

```console
Finding postcode information for longitude -2.36 and latitude 51.38
Found region South West
Found postcode BA1 1QF
Postcode is in Bath and North East Somerset district
```

## Acknowledgements

- To install updated versions of SQLite and Spatialite on MacOS the guide to [Installing and loading spatialite on MacOS by Tom C](https://medium.com/@carusot42/installing-and-loading-spatialite-on-macos-28bf677f0436) was really useful.

## Licence and attribution

The code in this repository is published under the [MIT Licence](LICENSE) and is free to use and reuse under the terms of that licence.

The ONS produce the postcode lookup products used in this product, but there are specific license and attribution terms. Please see [the ONS licenses page](https://www.ons.gov.uk/methodology/geography/licences) for more info.

> Our postcode products (derived from Code-Point® Open) are subject to the Open Government Licence.
>
> If you also use the Northern Ireland data (postcodes starting with “BT”), you need a separate licence for commercial use direct from Land and Property Services. We only issue a Northern Ireland End User Licence(for internal business use only) with the data. To download a copy, go to the “Download” section of this page. Use of the Northern Ireland data contained within the ONS postcode products constitutes acceptance of the Northern Ireland licensing terms and conditions.

The following attribution statements should be used but do always check the original licence pages for the data.

- Contains OS data © Crown copyright and database right 2023
- Contains Royal Mail data © Royal Mail copyright and database right 2023
- Source: Office for National Statistics licensed under the Open Government Licence v.3.0

Particularly with regard to Northern Ireland data, if you do not have a commercial licence you can remove the NI file.
