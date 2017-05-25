# if multiple files are to be indexed/inserted
shp2geojson_mult () {
    if [ "$multiple_files" = true ]
    then
        for i in "$shapefile_dir"/*shp
        do
            shp2geojson $i
        done
    else
        shp2geojson "$shapefile"
    fi
}

