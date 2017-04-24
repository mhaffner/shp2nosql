## remove database before inserting records
remove_database () {
    if [ "$remove" = "true" ] && [ "$db_type" = "elasticsearch" ]
    then
        ## check if index exists
        index_exists="$(curl -I "$host":"$port"/"$index_name")"
        if [[ "$index_exists" =~ .*"200"* ]]
        then
            echo "Removing index $index_name"
            curl -XDELETE "$host":"$port"/"$index_name"
        elif [[ "$index_exists" =~ .*"404"* ]]
        then
            echo "Index does not exist; nothing to remove"
        else
            echo "Connection refused. Is elasticsearch running?" >&2
            exit 1
        fi
    elif [ "$remove" = "true" ] && [ "$db_type" = "mongodb" ]
    then
        ## this does not throw an error if database doesn't exist
        mongo "$db_name" --eval "db.dropDatabase()"
        echo "Database deleted"
    fi
}

