shp2nosql \
    -R `# remove the database if it exists` \
    -d elasticsearch `# database type` \
    -f state `# file to get from US Census TIGER files` \
    -i us_states `# index name` \
    -t state `# document type`
