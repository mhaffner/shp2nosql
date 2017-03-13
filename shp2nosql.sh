#!/bin/bash

# get the directory of the package
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# preallocate variables
is_local=false
ip_address=localhost
port=9200
remove=false
use_esbulk=false

# with the exception of the documentation, these functions set
# variables and display warnings only

h_func () {
    cat help.txt
}

# check if shapefile is local or should be downloaded
l_func () {
    is_local=true
}

# download data from tiger or use local file
f_func () {
    # TODO what if this argument comes before -l ? (then is_local will be false)
    if [ $is_local = true ]
    then
        # need full path to shapefile for other operations?
        shapefile=$OPTARG; # arg should not be lowercased if user specifies file (case senstive directories)
        if [ -a $shapefile ] # check if shapefile exists
        then
            echo $shapefile
        else
            echo "File does not exist"
            exit 1
        fi
    else
        # "${OPTARG,,}" converts the argument to lowercase via bash string manipulation
        census_prod="${OPTARG,,}"
        if [ $census_prod != "state" ]  && \
               [ $census_prod != "county" ] && \
               [ $census_prod != "tract" ]
        then
            echo "Census retrieval must be either state, county, or tract" >&2
            exit 1
        fi
    fi
}

# get database type
d_func () {
    db_type="${OPTARG,,}"
    if [ $db_type = "es" ]
    then
        # TODO what if this argument comes after the port argument?
        port=9200
        echo "Using database type $db_type"
    elif
        [ $db_type = "mongo" ]
    then
        # TODO use appropriate default mongodb port
        port=9201
        echo "Using database type $db_type"
    else
        echo "Databse type must be either 'es' or 'mongo'" >&2
        exit 1
    fi
}

# get index name (Elasticsearch only)
i_func () {
    index_name=$OPTARG # should not be converted to lowercase; index names can be upper or lower
    echo "Using index $index_name"
}

# get document type (Elasticsearch only)
t_func () {
    doc_type=$OPTARG # should not be converted to lowercase; document types can be upper or lower
    echo "Using document type $doc_type"
}

# get database name (MongoDB only)
D_func () { database_name=$OPTARG # should not be converted to lowercase; document types can be upper or lower
            echo "Using database $database_name"
          }


# get the ip address
I_func () { ip_address=$OPTARG
            echo "Using ip address $ip_address"
          }

# get the port number
p_func () { port=$OPTARG
            echo "Using port $port" 
          }

# get state fips code
S_func () {
    state_fips=$OPTARG # should be numeric, no need to convert to lower
    #TODO check if fips is a two digit integer
    #TODO if not two digit, convert to two digit (e.g. 2 > 02)
    echo "Using state fips code $state_fips"
          }

# get user's option to remove the database/index before re-inserting/indexing
R_func () {
    remove=true
          }

e_func () {
    # check if esbulk is installed; if so, use it throughout
    if type esbulk >/dev/null 2>&1
    then
        use_esbulk=true
        echo "Will use the esbulk utility to index records"
    else
        echo "Either esbulk is not installed or its location was not found in PATH" >&2
    fi
}



# this exectues the above functions if the corresponding argument is given
options='hlf:d:D:i:t:I:p:S:Re'
while getopts $options option
do
    case $option in
        h  ) h_func; exit;; # HELP/documentation
        l  ) l_func;; # data source is LOCAL? (no arugment needed)
        f  ) f_func;; # FILE (if local), file-to-get-from-census (if not local)
        d  ) d_func;; # DATABASE type
        D  ) D_func;; # DATABASE name (MongoDB only)
        i  ) i_func;; # INDEX name (Elasticsearch only)
        t  ) t_func;; # document TYPE (Elasticearch only)
        I  ) I_func;; # IP address
        p  ) p_func;; # PORT
        S  ) S_func;; # STATE fips code (two digit)
        R  ) R_func;; # REMOVE database or index before reinserting records/documents
        e  ) e_func;; # use ESBULK (Elasticsearch only)
        \? ) echo "Unknown option: -$OPTARG" >&2; exit 1;;
        :  ) echo "Missing option argument for -$OPTARG" >&2; exit 1;;
        *  ) echo "Unimplemented option: -$OPTARG" >&2; exit 1;;
    esac
done

# shift $(($OPTIND - 1)) # necessary?

# get data from TIGER
wget_census_data () {
    if [ $is_local != true ] #TODO include extra checks
    then
        cd $script_dir/data/shapefiles # navigate to location of package
        if [ "$census_prod" = "county" ]
        then
            wget -nc ftp://ftp2.census.gov/geo/tiger/TIGER2016/COUNTY/tl_2016_us_county.zip
            if [ ! -e "tl_2016_us_county.shp" ]
            then
                unzip tl_2016_us_county.zip
            fi
            shapefile=$script_dir/data/shapefiles/tl_2016_us_county.shp
        elif [ "$census_prod" = "state" ]
        then
            wget -nc ftp://ftp2.census.gov/geo/tiger/TIGER2016/STATE/tl_2016_us_state.zip
            if [ ! -e "tl_2016_us_state.shp" ]
            then
                unzip tl_2016_us_state.zip
            fi
            shapefile=$script_dir/data/shapefiles/tl_2016_us_state.shp
        elif [ "$census_prod" = "tract" ]
        then
            wget -nc ftp://ftp2.census.gov/geo/tiger/TIGER2016/TRACT/tl_2016_"$state_fips"_tract.zip
            if [ ! -e "tl_2016_${state_fips}_tract.shp" ]
            then
                unzip tl_2016_"$state_fips"_tract.zip
            fi
            shapefile=$script_dir/data/shapefiles/tl_2016_"$state_fips"_tract.shp
        fi
    fi
}

# convert shapefile to .geojson
geojson_conversion () {
    cd $script_dir/data/geojson
    if [ -a $shapefile ] # check if shapefile exists
    then
        geojson=$(basename "$shapefile" .shp).geojson # use basename of file to create .geojson name
        echo "Converting shapefile to .geojson"
        ogr2ogr -f GeoJSON $geojson $shapefile -t_srs http://spatialreference.org/ref/epsg/4326/ # let users specify manually?
    else
        echo "Shapefile does not exist"
    fi
}

# format geojson for elasticsearch
format_for_es () {
    cd $script_dir/data/geojson

    if [ -a $geojson ] # check if geojson exists
    then
        # use basename of geojson to create es formatted .geojson name
        geojson_es=$(basename "$geojson" .geojson)_es.geojson
        # TODO remove this and just use one file?
        cp $geojson $geojson_es

        ## delete the first four lines
        sed -i '1,4d' $geojson_es

        ## delete last character if it's a comma; we don't want a json array
        sed -i 's/,$//' $geojson_es

        # remove the last two lines
        sed -i '$d' $geojson_es
        sed -i '$d' $geojson_es
        
        ## steps below not necessary if esbulk is installed
        if [ $use_esbulk = "false" ]
        then
            # satisfy requirements of the bulk api
            sed -i 's/^/{ "index" : { "_index" : \"'"$index_name"'\", "_type" : \"'"$doc_type"'\" } }\n/' $geojson_es # insert index info on each line

            # add newline to end of file to satisfy bulk api
            sed -i '$a\' $geojson_es
        fi
    else
        echo "Geojson conversion for elasticsearch failed"
    fi
}

remove_database () {
    if [ $remove = "true" ] && [ $db_type = "es" ]
    then
        # TODO if index exists.... how to best get curl output from es and process?
        echo "Removing index $index_name"
        curl -XDELETE "$ip_address":"$port"/"$index_name"
    fi
}

input_mapping () {

    ## navigate to location of mapping
    cd $script_dir/data/mappings

    ## first line of geojson will be different if esbulk is not installed
    if [ $use_esbulk = "true" ]
    then
        # get first line of geojson
        head -1 $script_dir/data/geojson/$geojson_es | cat mapping-template.json - > index-sample.json
    else
        # get second line of geojson (first line contains request)
        sed '2q;d' $script_dir/data/geojson/$geojson_es | cat mapping-template.json - > index-sample.json
    fi

    curl -s -XPOST "$ip_address":"$port"/_bulk --data-binary @index-sample.json

    ## get mapping with curl; it will not be pretty
    curl -XGET "$ip_address":"$port"/mapping_sample__/_mapping > mapping-sample.json
    ## make mapping pretty
    ## TODO can do this in one step above with correct command
    python -m json.tool mapping-sample.json > mapping-pretty.json

    ## delete the index; we will make it cooler (e.g. have a spatial index)
    curl -XDELETE "$ip_address":"$port"/mapping_sample__

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
}

insert_records () {
    cd $script_dir/data/geojson

    if [ $db_type = "es" ]
    then
        echo "Indexing documents into elasticsearch"
        if [ $use_esbulk = "true" ]
        then
            #TODO allow for remote connection
            esbulk -index $index_name -port $port -type $doc_type $geojson_es -verbose
        else
            #TODO currently this does not work; results in 413 error
            #specifying max doc size in elasticsearch.yml does not help
            numlines=$(wc -l < "$geojson_es")
            if [ $numlines -gt 2000 ]
            then
                # TODO if esbulk is not used, will need to break into chunks of 1-2k records manually
                echo "Too many records in one file; splitting into chunks"
                # put the split files in a different directory
                cd split_dir
                split -l 2000 ../"$geojson_es" split_file # split_file will be prefix
                for i in split_file*
                do
                    echo "Indexing chunk $i"
                    curl -s XPOST "$ip_address":"$port"/_bulk --data-binary @"$i"
                done
#                rm split_file* # cleanup
            else
                curl -s XPOST "$ip_address":"$port"/_bulk --data-binary @"$geojson_es"
            fi
        fi
    fi
}

# how to handle these??? execute all or use if/else -> I think handle if/else in these functions (above)
wget_census_data
geojson_conversion
remove_database
format_for_es
input_mapping
insert_records

echo "Complete"
