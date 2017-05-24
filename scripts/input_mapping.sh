## in order to use a spatial index, you must first define the geometry field as
## type "geo_shape" (points must be listed in this way as well if they are to
## use spatial functions). The trick with this is that you cannot redefine field
## mappings after the index is created. The strategy here is to input one
## record, get the mapping and save it in a file, delete the index, modify the
## mapping slightly, create an index with no records, and input the field
## mappings. Then you can index records. Whew! Good thing this function exists!

input_mapping () {
    if [ "$db_type" = "elasticsearch" ]
    then
        ## navigate to location of mapping
        cd "$pkg_dir"/data/mappings

        ## first line of geojson will be different if esbulk is not installed
        if [ "$use_esbulk" = "true" ]
        then
            # get first line of geojson
            head -1 "$pkg_dir"/data/geojson/"$geojson_fmt" | cat mapping-template.json - > index-sample.json
        else
            # get second line of geojson (first line contains request)
            sed '2q;d' "$pkg_dir"/data/geojson/"$geojson_fmt" | cat mapping-template.json - > index-sample.json
        fi

        curl -s -XPOST "$host":"$port"/_bulk --data-binary @index-sample.json

        ## get mapping with curl; it will not be pretty
        curl -XGET "$host":"$port"/mapping_sample__/_mapping > mapping-sample.json

        ## make mapping pretty
        python -m json.tool mapping-sample.json > mapping-pretty.json

        ## delete the index; we will make it cooler (e.g. have a spatial index)
        curl -XDELETE "$host":"$port"/mapping_sample__

        ## delete third and fourth lines
        sed -i '3,4d' mapping-pretty.json
        ## insert proper info for geo_index
        sed -i '/geometry": {/a "type"\: "geo_shape"\n},' mapping-pretty.json
        ## delete lines 7-21
        sed -i '7,21d' mapping-pretty.json
        ## delete last two lines
        sed -i '$d' mapping-pretty.json
        sed -i '$d' mapping-pretty.json
        ## replace psuedo index name with actual
        sed -i 's/mapping_sample__/'"$doc_type"'/' mapping-pretty.json
        ## create trivial index (with no documents)
        curl -XPUT "$host":"$port"/"$index_name"
        ## input mapping
        curl -XPUT "$host":"$port"/"$index_name"/_mapping/"$doc_type" --data @mapping-pretty.json
    fi
}

