sed 's/\"//g' data/ONSPD_*_UK.csv | awk -F',' '{if (NR != 1 && $5 == "") { print $1","$6","$8","$17","$18","$20","$43","$44 } }' > data/postcodes.csv
find data -type f -name "Country names*" -exec mv -f {} data/countries.csv \;
find data -type f -name "County names*" -exec mv -f {} data/counties.csv \;
find data -type f -name "LA_UA names*" -exec mv -f {} data/districts.csv \;
find data -type f -name "Region names*" -exec mv -f {} data/regions.csv \;
find data -type f -name "Westminster Parliamentary Constituency names*" -exec mv -f {} data/constituencies.csv \;