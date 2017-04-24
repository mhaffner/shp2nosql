# get data from TIGER
wget_census_data () {
    if [ "$is_local" != true ]
    then
        cd "$script_dir"/data/shapefiles # navigate to location of package
        if [ "$census_prod" = "county" ]
        then
            wget -nc https://www2.census.gov/geo/tiger/TIGER2016/COUNTY/tl_2016_us_county.zip
            if [ ! -e "tl_2016_us_county.shp" ]
            then
                unzip tl_2016_us_county.zip
            fi
            shapefile="$script_dir"/data/shapefiles/tl_2016_us_county.shp
        elif [ "$census_prod" = "state" ]
        then
            wget -nc https://www2.census.gov/geo/tiger/TIGER2016/STATE/tl_2016_us_state.zip
            if [ ! -e "tl_2016_us_state.shp" ]
            then
                unzip tl_2016_us_state.zip
            fi
            shapefile="$script_dir"/data/shapefiles/tl_2016_us_state.shp
        elif [ "$census_prod" = "tract" ]
        then
            if [ -z "$state_fips" ]
            then
                echo "Two digit state fips code must be specified with the -S option" >&2
                exit 1
            else
                wget -nc https://www2.census.gov/geo/tiger/TIGER2016/TRACT/tl_2016_"$state_fips"_tract.zip
                if [ ! -e "tl_2016_${state_fips}_tract.shp" ]
                then
                    unzip tl_2016_"$state_fips"_tract.zip
                fi
            fi
            shapefile="$script_dir"/data/shapefiles/tl_2016_"$state_fips"_tract.shp
        fi
    fi
}
