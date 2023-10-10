import sys
import spatialite

longitude = sys.argv[1]
latitude = sys.argv[2]

print("Finding postcode information for longitude " +
      longitude + " and latitude " + latitude)

with spatialite.connect('database/regions_geo.sqlite') as region_db, spatialite.connect('database/postcodes.sqlite') as postcode_lookup_db:
    region_result = region_db.execute('select code, name from regions where within(makepoint(?, ?, 4326), geom)', [
                                      float(longitude), float(latitude)]).fetchone()
    if region_result is None:
        print("No region found")
        sys.exit(1)
    else:
        print("Found region " + region_result[1])

        region_name_lower = region_result[1].replace(' ', '_').lower()
        db_name = 'database/postcodes_geo_' + region_name_lower + '.sqlite'

        with spatialite.connect(db_name) as postcode_geo_db:
            postcode_result = postcode_geo_db.execute('select postcode from postcodes order by distance(makepoint(?, ?, 4326), geom) limit 1', [
                float(longitude), float(latitude)]).fetchone()
            if postcode_result is None:
                print("No postcode found")
                sys.exit(1)
            else:
                print("Found postcode " + postcode_result[0])

                postcode_info = postcode_lookup_db.execute(
                    'select * from vw_postcodes where postcode = ?', [postcode_result[0]]).fetchone()
                if postcode_info is None:
                    print("No postcode information found")
                    sys.exit(1)
                else:
                    print("Postcode is in " + postcode_info[3] + " district")
                    sys.exit(0)
