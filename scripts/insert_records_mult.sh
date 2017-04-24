## check if multiple_files option is selected, then use insert_records function
insert_records_mult () {
    if [ "$multiple_files" = true ]
    then
        for i in "$shapefile_dir"/*shp
        do
            ## need to get the name of each geojson based on the shapefile names
            geojson="$(basename "$i" .shp).geojson"
            ## need to get the name of each geojson_fmt based on geojson name
            geojson_fmt="$(basename "$geojson" .geojson)"_fmt.geojson
            insert_records "$geojson_fmt"
        done
    else
        insert_records "$geojson_fmt"
    fi
}

