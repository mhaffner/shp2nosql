#!/bin/bash

#TODO navigate to current directory because of realtive path names
#TODO convert OPTARG's to local (see line 14)

# preallocate variables
is_local=false

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
                shapefile=$OPTARG;
                if [ -a $shapefile ] # check if shapefile exists
                then
                    echo $shapefile
                else
                    echo "File does not exist"
                    # exit if file does not exist?
                    exit 1
                fi
            else
                census_prod="$OPTARG"
                if [ $census_prod != "STATE" ]  && [ $census_prod != "COUNTY" ]
                then
                    echo "Census retrieval must be eiter country or state"
                fi
            fi
          }

# get database type
d_func () { db_type=$OPTARG
            if [ $db_type != "ES" ] && [ $db_type != "MONGO" ]
            then
                echo "Databse type must be either 'ES' or 'MONGO' "
            else
                echo "Using database type $db_type"
            fi
          }

# get index name (Elasticsearch only)
i_func () { index_name=$OPTARG
            echo "Using index $index_name"
          }

# get document type (Elasticsearch only)
t_func () { doc_type=$OPTARG
            echo "Using document type $document_type"
          }

# get database name (MongoDB only)
D_func () { database_name=$OPTARG
            echo "Using database $database_name"
          }

# get state fips code
S_func () { state_fips=$OPTARG
          }


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
        h  ) usage; exit;; # HELP
        \? ) echo "Unknown option: -$OPTARG" >&2; exit 1;;
        :  ) echo "Missing option argument for -$OPTARG" >&2; exit 1;;
        *  ) echo "Unimplemented option: -$OPTARG" >&2; exit 1;;
    esac
done

# shift $(($OPTIND - 1)) # necessary?

# download data using wget from census?

# insert records into appropriate database
# insert_func;

# get data from TIGER
wget_func () { if [ $is_local != true ] #TODO include extra checks
               then
                   # will need to be changed if user runs this somewhere other than in this dir
                   cd ./data/shapefiles
                   if [ "$census_prod" = "COUNTY" ]; then
                       wget -nc ftp://ftp2.census.gov/geo/tiger/TIGER2016/COUNTY/tl_2016_us_county.zip
                       if [ ! -e tl_2016_us_county.zip ]
                       then
                          unzip tl_2016_us_county.zip
                       fi
                       shapefile=tl_2016_us_county.shp
                   elif [ "$census_prod" = "STATE" ]; then
                       wget -nc ftp://ftp2.census.gov/geo/tiger/TIGER2016/STATE/tl_2016_us_state.zip
                       if [ ! -e "tl_2016_us_state.zip" ]
                       then
                          unzip tl_2016_us_state.zip
                       fi
                       shapefile=tl_2016_us_state.shp
                   fi
               fi
             }

# convert shapefile to .geojson
geojson_func () {
    if [ -a $shapefile ] # check if shapefile exists
    target_file=$(basename "$shapefile" .shp).geojson # use basename of file to create .geojson name
    echo "Converting shapefile to .geojson"
    ogr2ogr -f GeoJSON $target_file $shapefile #-t_srs http://spatialreference.org/ref/epsg/4326/ # let users specify manually?
}


# insert records into appropriate database
# insert_func() { if [ db_type = "ES" ]
#                then
#                    # curl blah blah blah...
#                elif [ db_type = "MONGO" ]
#                then
#                     # curl blah blah blah...
#                fi
#              }
# execute commands

wget_func
#geojson_func
#insert_func
