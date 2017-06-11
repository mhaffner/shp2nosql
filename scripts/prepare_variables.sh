# with the exception of displaying the documentation, these functions set
# variables and display warnings only

is_local=false
multiple_files=false
host=localhost
remove=false
use_esbulk=false

if [ "$db_type" = "elasticsearch" ]
then
    port=9200
else
    port=27017
fi

# display help/documentation
h_opt () {
    if [ "$db_type" = "elasticsearch" ]
    then
        cat "$pkg_dir"/elasticsearch-help.txt
    else
        cat "$pkg_dir"/mongodb-help.txt
    fi
}

# check if shapefile is local or should be downloaded
l_opt () {
    is_local=true
    shapefile="$OPTARG"
    shapefile="$(realpath $shapefile)" # this allows input to be relative path to file
    if [ -a "$shapefile" ] # check if shapefile exists
    then
        echo "Using shapefile $shapefile"
    else
        echo "File does not exist"
        exit 1
    fi
}

# use this option if using multiple files (no need to specify -l as well)
m_opt () {
    is_local=true
    multiple_files=true
    shapefile_dir="$OPTARG"
    shapefile_dir="$(realpath $shapefile_dir)" # this allows input to be relative path to file
    if [ -d "$shapefile_dir" ]
    then
        # get number of files in directory; pipe ls output to grep (shp$ means no
        # .shp.xml, .shp.iso.xml, etc.) then count lines
        num_files=$(ls "$shapefile_dir" | grep shp$ | wc -l)
        echo "Directory of shapfiles is $shapefile_dir"
        echo "$num_files files present"
    else
        echo "Input must be a directory" >&2
    fi
}

f_opt () {
    # "${OPTARG,,}" converts the argument to lowercase via bash string manipulation
    census_prod="${OPTARG,,}"
    if [ $census_prod != "state" ]  && \
           [ $census_prod != "county" ] && \
           [ $census_prod != "tract" ]
    then
        echo "Census retrieval must be either state, county, or tract" >&2
        exit 1
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

# get index name (Elasticsearch only)
i_opt () {
    index_name="$OPTARG" # should not be converted to lowercase; index names can be upper or lower
    echo "Using index $index_name"
}

# get document type (Elasticsearch only)
t_opt () {
    doc_type="$OPTARG" # should not be converted to lowercase; document types can be upper or lower
    echo "Using document type $doc_type"
}

# get database name (MongoDB only)
d_opt () {
    db_name="$OPTARG" # should not be converted to lowercase; database names can be upper or lower
    echo "Using database $db_name"
}

# get collection name (MongoDB only)
c_opt () {
    collection_name="$OPTARG" # should not be converted to lowercase; collection names can be upper or lower
    echo "Using collection $collection_name"
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

# use esbulk to index documents; check if it is installed
e_opt () {
    if type esbulk >/dev/null 2>&1
    then
        use_esbulk=true
        echo "Will use the esbulk utility to index records"
    else
        echo "Either esbulk is not installed or its location was not found in PATH" >&2
    fi
}
