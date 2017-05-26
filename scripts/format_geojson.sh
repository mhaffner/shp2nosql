# format geojson for elasticsearch and mongodb
format_geojson_single () {
    cd "$pkg_dir"/data/geojson
    if [ -a "$1" ] # check if geojson exists
    then
        echo "Formatting geojson for database"
        # use basename of geojson to create es formatted .geojson name
        geojson_fmt="$(basename "$1" .geojson)"_fmt.geojson
        # TODO remove this and just use one file?
        cp "$1" "$geojson_fmt"

        ## delete the first four lines
        sed -i '1,4d' "$geojson_fmt"

        ## delete last character if it's a comma; we don't want a json array
        sed -i 's/,$//' "$geojson_fmt"

        # remove the last two lines
        sed -i '$d' "$geojson_fmt"
        sed -i '$d' "$geojson_fmt"

        ## steps below not necessary if using mongodb or esbulk is installed
        if [ "$use_esbulk" = "false" ] && [ "$db_type" = "elasticsearch" ]
        then
            # satisfy requirements of the bulk api
            sed -i 's/^/{ "index" : { "_index" : \"'"$index_name"'\", "_type" : \"'"$doc_type"'\" } }\n/' "$geojson_fmt" # insert index info on each line

            # add newline to end of file to satisfy bulk api
            sed -i '$a\' "$geojson_fmt"
        fi
    else
        echo "Geojson conversion for elasticsearch failed"
    fi
}

# check if there are multiple files, then format
format_geojson () {
    if [ "$multiple_files" = true ]
    then
        for i in "$shapefile_dir"/*shp
        do
            ## need to get the name of each geojson based on the shapefile names
            geojson="$(basename "$i" .shp).geojson"
            format_geojson_single $geojson
        done
    else
        format_geojson_single "$geojson"
    fi
}

