rm -f database/postcodes.sqlite
/usr/local/Cellar/sqlite/3.43.1/bin/sqlite3 "database/postcodes.sqlite" ".read scripts/create_postcodes_lookup.sql"