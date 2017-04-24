insert_records () {
    cd "$script_dir"/data/geojson

    if [ "$db_type" = "elasticsearch" ]
    then
        printf "\nIndexing documents into elasticsearch"
        if [ "$use_esbulk" = "true" ]
        then
            #TODO allow for remote connection
            #esbulk -index "$index_name" -port "$port" -type "$doc_type" "$1" -verbose
            esbulk -index "$index_name" -host "$host" -port "$port" -type "$doc_type" "$1" -verbose
        else
            #specifying max doc size in elasticsearch.yml does not help
            num_lines=$(wc -l < "$1")
            # split files up if there are too many (3k line limit in Elasticsearch?)
            if [ "$num_lines" -gt 3000 ]
            then
                printf "\nToo many records in one file; splitting into chunks"
                # put the split files in a different directory
                cd split_dir
                split -l 2000 ../"$1" split_file # split_file will be prefix
                for i in split_file*
                do
                    printf "\nIndexing chunk $i"
                    curl -s XPOST "$host":"$port"/_bulk --data-binary @"$i"
                done
                rm split_file* # cleanup
            else
                curl -s XPOST "$host":"$port"/_bulk --data-binary @"$1"
            fi
        fi
    elif [ "$db_type" = "mongodb" ]
    then
        echo "Inserting records into MongoDB"
        mongoimport --db "$db_name" --collection "$collection_name" --file "$1" --host "$host":"$port"
    fi
}

