rm -f database/regions_geo.sqlite
/usr/local/Cellar/sqlite/3.43.1/bin/sqlite3 "database/regions_geo.sqlite" ".read scripts/create_regions_geo.sql"