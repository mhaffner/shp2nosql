#!/bin/bash

# documentation
usage () { echo "How to use"; }

# download data from tiger
f_func () { cd ./data/shapefiles
            if [ "$OPTARG" = "COUNTY" ]
            then
                wget ftp://ftp2.census.gov/geo/tiger/TIGER2016/COUNTY/tl_2016_us_county.zip ;
                unzip tl_2016_us_county.zip
            elif [ "$OPTARG" = "STATE" ]
            then
                wget ftp://ftp2.census.gov/geo/tiger/TIGER2016/STATE/tl_2016_us_state.zip ;
                unzip tl_2016_us_state.zip
            fi
          }

options='s:f:h'
while getopts $options option
do
    case $option in
        s  ) i_func;;
        f  ) f_func;;
        h  ) usage; exit;;
        \? ) echo "Unknown option: -$OPTARG" >&2; exit 1;;
        :  ) echo "Missing option argument for -$OPTARG" >&2; exit 1;;
        *  ) echo "Unimplemented option: -$OPTARG" >&2; exit 1;;
    esac
done
