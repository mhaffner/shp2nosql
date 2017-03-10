script_dir=/home/matt/git-repos/shp2nosql
esbulk_installed=true
ip_address=localhost
port=9200
index_name=sample
doc_type=state
geojson_es=/home/matt/git-repos/shp2nosql/data/geojson/tl_2016_us_state_es.geojson

input-mapping () {

    ## navigate to location of mapping
    cd $script_dir/data/mappings

    ## first line of geojson will be different if esbulk is not installed
    if [ $esbulk_installed = "true" ]
    then
        # TODO DELETE THIS LINE BEFORE PUTTING INTO ACTUAL SCRIPT
        curl -XDELETE localhost:9200/"$index_name"
        head -1 $geojson_es | cat mapping-template.json - > index-sample.json

        curl -s -XPOST "$ip_address":"$port"/_bulk --data-binary @index-sample.json

        ## get mapping with curl; it will not be pretty
        curl -XGET "$ip_address":"$port"/mapping_sample__/_mapping > mapping-sample.json
        ## make mapping pretty
        python -m json.tool mapping-sample.json > mapping-pretty.json

        ## delete the index; we will make it cooler (e.g. have a spatial index)
        curl -XDELETE "$ip_address":"$port"/mapping_sample__/

        ## do the magic (see README on "for mapping")

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
        curl -XPUT "$ip_address":"$port"/"$index_name"
        ## input mapping
        curl -XPUT "$ip_address":"$port"/"$index_name"/_mapping/"$doc_type" --data @mapping-pretty.json
    fi
}


input-mapping
