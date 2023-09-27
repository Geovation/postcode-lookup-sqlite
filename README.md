# Postcode lookup - SQLite

A project to create a small SQLite database that can be used as a postcode lookup with various admin geographies. Primarily built with data from the ONS Postcode directory.

# Database specification

The database provides the following:

* Coordinates in lat/lng for all active postcodes


# Fresh files guide

The database is built from files published in the [ONS Postcode Directory Lookup](https://geoportal.statistics.gov.uk/search?collection=Dataset&sort=-created&tags=all(PRD_ONSPD))

1. Download the [latest ONS Postcode Directory Lookup](https://geoportal.statistics.gov.uk/search?collection=Dataset&sort=-created&tags=all(PRD_ONSPD)). This will be provided in a zip file. 
2. Extract the file into the data directory. It will be called something like `ONSPD_AUG_2023_UK.csv`. The file can change format, so these scripts will need to be maintained for it to always work with the latest version.
3. Also extract the following files, which should be in the `documents` directory of the download. Copy these to the data directory.

```
Country names and codes UK as at 08_12.csv,County names and codes UK as at 04_21.csv,LA_UA names and codes UK as at 04_23.csv,Region names and codes EN as at 12_20 (RGN).csv,Westminster Parliamentary Constituency names and codes UK as at 12_14.csv
```

3. At a Linux based command line, within this root directory, run the following (adjusting the filename as required)

```console
./process_files.sh
```

This extracts the following fields (with field position):

- PCD(1): Unit postcode – 7 character version
- OSCTY(6): County
- OSLAUA(8): Local authority district (LAD)/unitary authority (UA)/ metropolitan district (MD)/ London borough (LB)/ council area (CA)/district council area (DCA)
- CTRY(17): Country
- RGN(18): Region
- PCON(20): Westminster parliamentary constituency
- LAT(43): Decimal degrees latitude
- LONG(44): Decimal degrees longitude

This will process the ONS postcode directory into a smaller file.

4. Run the following to generate the indexed SQLite database.

# Licence and attribution

The code in this repsoitory is published under the [MIT Licence](LICENSE) and is free to use and reuse.

The data 