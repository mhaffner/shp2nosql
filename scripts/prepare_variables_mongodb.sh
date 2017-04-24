# preallocate variables
is_local=false
multiple_files=false
host=localhost
remove=false
db_type=mongodb

# with the exception of the documentation, these functions set
# variables and display warnings only

h_opt () {
    cat "$script_dir"/help.txt
}

# check if shapefile is local or should be downloaded
l_opt () {
    is_local=true
}

# use this option if using multiple files (no need to specify -l as well)
m_opt () {
    multiple_files=true
    is_local=true
}
f_opt () {
    if [ "$is_local" = true ]
    then
        if [ "$multiple_files" = true ]
        then
            shapefile_dir="$OPTARG"
            shapefile_dir="$(realpath $shapefile_dir)" # this allows input to be relative path to file
            # get number of files in directory; pipe ls output to grep (shp$ means no .shp.xml, .shp.iso.xml, etc.) then count lines
            num_files=$(ls "$shapefile_dir" | grep shp$ | wc -l)
            echo "Directory of shapfiles is $shapefile_dir"
            echo "$num_files files present"
            #exit 0
        else
            shapefile="$OPTARG"
            shapefile="$(realpath $shapefile)" # this allows input to be relative path to file
            if [ -a "$shapefile" ] # check if shapefile exists
            then
                echo "Using shapefile $shapefile"
            else
                echo "File does not exist"
                exit 1
            fi
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

# get state fips code
s_opt () {
    state_fips="$OPTARG" # should be numeric, no need to convert to lower
    num_digits="${#state_fips}"
    if [ "$num_digits" -eq 2 ]
    then
        echo "Using state fips code $state_fips"
    elif [ "$num_digits" -eq 1 ]
    then
        state_fips=0"$state_fips"
        echo "Using state fips code $state_fips"
    else
        echo "State fips code must be a two digit integer"
    fi
}

# get database name
d_opt () {
    db_name="$OPTARG" # should not be converted to lowercase; document types can be upper or lower
    echo "Using database $db_name"
}

# get host (external ip_address)
H_opt () {
    host="$OPTARG"
    echo "Using host $host"
}

# get the port number (default's are set in d_opt)
p_opt () {
    port="$OPTARG"
    echo "Using port $port"
}

# get user's option to remove the database/index before re-inserting/indexing
r_opt () {
    remove=true
}
