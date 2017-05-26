# convert shapefile to .geojson
shp2geojson_single () {
    echo "$pkg_dir"
    cd "$pkg_dir"/data/geojson
    if [ -a "$1" ] # check if shapefile exists
    then
        geojson="$(basename "$1" .shp).geojson" # use basename of file to create .geojson name
        echo "Converting shapefile to .geojson"
        ogr2ogr -f GeoJSON "$geojson" "$1" -t_srs EPSG:4326
        #http://spatialreference.org/ref/epsg/4326/ not working anymore?
    else
        echo "Shapefile does not exist" >&2
        exit 1
    fi
}

# check if multiple files are present, then convert
shp2geojson () {
    if [ "$multiple_files" = true ]
    then
        for i in "$shapefile_dir"/*shp
        do
            shp2geojson_single $i
        done
    else
        shp2geojson_single "$shapefile"
    fi
}

