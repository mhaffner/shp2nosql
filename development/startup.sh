#!/bin/bash

# start elasticsearch and mongodb
echo "Preparing Elasticsearch and MongoDB..."
./elasticsearch-5.5.2/bin/elasticsearch & disown
echo "Elasticsearch started"
./mongodb-linux-x86_64-3.4.7/bin/mongod & disown
echo "MongoDB started"
