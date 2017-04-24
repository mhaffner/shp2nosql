format_geojson_mult () {
    if [ "$multiple_files" = true ]
    then
        for i in "$shapefile_dir"/*shp
        do
            ## need to get the name of each geojson based on the shapefile names
            geojson="$(basename "$i" .shp).geojson" 
            format_geojson $geojson # 
        done
    else
        format_geojson "$geojson"
    fi
}

