#!/bin/bash

# get the directory of the package
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo $script_dir

# preallocate variables
is_local=false
ip_address=localhost
port=9200

# check if esbulk is installed; if so, use it throughout
#TODO esbulk still not appearing on path?
if type esbulk >/dev/null 2>&1
then
    esbulk_installed=true
else
    esbulk_installed=true
fi

# with the exception of the documentation, these functions set
# variables and display warnings only

usage () {
           cat help.txt
         }


# check if shapefile is local or should be downloaded
s_func () { if [ "${OPTARG,,}" = "local" ] # "${OPTARG,,}" converts the argument to lowercase via bash string manipulation
            then
                is_local=true
                echo "Using local file."
                echo "${OPTARG,,}"
            else
                is_local=false
                echo "Getting data from US Census."
                echo "${OPTARG,,}"
            fi
          }

# download data from tiger or use local file
f_func () { if [ $is_local = true ]
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
                census_prod="${OPTARG,,}"
                if [ $census_prod != "state" ]  && [ $census_prod != "county" ] #TODO add census tracts
                then
                    echo "Census retrieval must be eiter country or state"
                fi
            fi
          }

# get database type
d_func () { db_type="${OPTARG,,}"
            if [ $db_type = "es" ]
            then
                port=9200
                echo "Using database type $db_type"
            elif
                [ $db_type = "mongo" ]
            then
                port=9201
                echo "Using database type $db_type"
            else
                echo "Databse type must be either 'es' or 'mongo' "
            fi
          }

# get index name (Elasticsearch only)
i_func () { index_name=$OPTARG # should not be converted to lowercase; index names can be upper or lower
            echo "Using index $index_name"
          }

# get document type (Elasticsearch only)
t_func () { doc_type=$OPTARG # should not be converted to lowercase; document types can be upper or lower
            echo "Using document type $doc_type"
          }

# get database name (MongoDB only)
D_func () { database_name=$OPTARG # should not be converted to lowercase; document types can be upper or lower
            echo "Using database $database_name"
          }

# get state fips code
S_func () { state_fips=$OPTARG # should be numeric, no need to convert to lower
            #TODO check if fips is a two digit integer
            echo "Using state fips code $state_fips"
          }

# get the ip address
I_func () { ip_address=$OPTARG
            echo "Using ip address $ip_address"
          }

# get the port number
p_func () { port=$OPTARG
   echo "Using port $port" 
}


# this exectues the above functions if the corresponding argument is given
options='s:f:d:D:i:t:h'
while getopts $options option
do
    case $option in
        s  ) s_func;; # SOURCE
        f  ) f_func;; # FILE (if local), file-to-get-from-census (if not local)
        d  ) d_func;; # DATABASE type
        D  ) D_func;; # DATABASE name (MongoDB only)
        i  ) i_func;; # INDEX name (Elasticsearch only)
        t  ) t_func;; # document TYPE (Elasticearch only)
        I  ) I_func;; # ip address
        p  ) p_func;; # port
        h  ) usage; exit;; # HELP
        \? ) echo "Unknown option: -$OPTARG" >&2; exit 1;;
        :  ) echo "Missing option argument for -$OPTARG" >&2; exit 1;;
        *  ) echo "Unimplemented option: -$OPTARG" >&2; exit 1;;
    esac
done

# shift $(($OPTIND - 1)) # necessary?

# get data from TIGER
wget_func () { if [ $is_local != true ] #TODO include extra checks
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
                   fi
               fi
             }

# convert shapefile to .geojson
geojson_func () {
    cd $script_dir/data/geojson
    if [ -a $shapefile ] # check if shapefile exists
    then
        geojson=$(basename "$shapefile" .shp).geojson # use basename of file to create .geojson name
        echo "Converting shapefile to .geojson"
        ogr2ogr -f GeoJSON $geojson $shapefile
        #-t_srs http://spatialreference.org/ref/epsg/4326/ # let users specify manually?
    else
        echo "Shapefile does not exist"
    fi
}

# format geojson for elasticsearch
format-for-es () {
    cd $script_dir/data/geojson

    if [ -a $geojson ] # check if geojson exists
    then
        # use basename of geojson to create es formatted .geojson name
        geojson_es=$(basename "$geojson" .geojson)_es.geojson
        cp $geojson $geojson_es

        ## delete the first three lines
        sed -i '1,3d' $geojson_es

        ## delete last character if it's a comma; we don't want a json array
        sed -i 's/,$//' $geojson_es

        # remove the last two lines
        sed -i '$d' $geojson_es
        sed -i '$d' $geojson_es

        ## steps below not necessary if esbulk is installed
        if [ $esbulk_installed = "false" ]
        then
            # satisfy requirements of the bulk api
            sed -i 's/^/{"index" : { "_index" : \"'"$index_name"'\", "_type" : \"'"$doc_type"'\"} }\n/' $geojson_es # insert index info on each line

            # add newline to end of file to satisfy bulk api
            sed -i '$a\' $geojson_es
        fi
    fi
}

insert-func () {
    if [ $db_type = "es" ]
    then
        echo "Indexing documents into elasticsearch"
        if [ $esbulk_installed = "true" ]
        then
            #TODO allow for remote connection
            esbulk -index $index_name -port $port -type $doc_type $geojson_es -verbose
        else
            #TODO currently this does not work; results in 413 error
            #specifying max doc size in elasticsearch.yml does not help
            curl -s XPOST https://$"ip_address":"$port"/_bulk --data @"$geojson_es"
        fi
    fi
}

wget_func
geojson_func
format-for-es
insert-func
