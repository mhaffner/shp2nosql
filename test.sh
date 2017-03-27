host=localhost
port=9200
index_name=dc_tracts

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
