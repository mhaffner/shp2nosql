#!/bin/bash

# preallocate variables
is_local=false

# documentation
usage () { echo "How to use"; }

# check if file is local or should be downloaded
s_func () { if [ "$OPTARG" = "LOCAL" ]
            then
                is_local=true
            fi
          }

# download data from tiger or use local file
f_func () { if [ $is_local = true ]
            then
                echo "Local file being used"
                shapefile=$OPTARG;
                if [ -a $shapefile ]
                then
                    echo $shapefile
                else
                    echo "File does not exist"
                fi
            else
                cd ./data/shapefiles
                if [ "$OPTARG" = "COUNTY" ]
                then
                    wget ftp://ftp2.census.gov/geo/tiger/TIGER2016/COUNTY/tl_2016_us_county.zip
                    unzip tl_2016_us_county.zip
                    shapefile=tl_2016_us_county.shp
                elif [ "$OPTARG" = "STATE" ]
                then
                    wget ftp://ftp2.census.gov/geo/tiger/TIGER2016/STATE/tl_2016_us_state.zip
                    unzip tl_2016_us_state.zip
                    shapefile=tl_2016_us_state.shp
                fi
            fi
          }

# get database type
d_func () { db_type=$OPTARG
            echo $db_type }

# get index name (Elasticsearch only)
i_func () { index_name=$OPTARG }

# get document type (Elasticsearch only)
t_func () { doc_type=$OPTARG }

# get database name (MongoDB only)
D_func () { database_name=$OPTARG }

# get state fips code
S_func () { state_fips=$OPTARG }

# insert records into appropriate database
insert_func() { if [ db_type = "ES" ]
                then
                    #TODO curl blah blah blah...
                elif [ db_type = "MONGO" ]
                then
                     #TODO curl blah blah blah...
                fi
              }

options='s:f:d:D:h'
while getopts $options option
do
    case $option in
        s  ) s_func;;
        f  ) f_func;;
        d  ) d_func;;
        D  ) D_func;;
        i  ) i_func;;
        t  ) t_func;;
        h  ) usage; exit;;
        \? ) echo "Unknown option: -$OPTARG" >&2; exit 1;;
        :  ) echo "Missing option argument for -$OPTARG" >&2; exit 1;;
        *  ) echo "Unimplemented option: -$OPTARG" >&2; exit 1;;
    esac
done

# download data using wget from census?

# insert records into appropriate database
insert_func;
