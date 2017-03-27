shp2nosql \
    -R `# remove the database if it exists` \
    -d elasticsearch `# database type` \
    -f tract `# file to get from US Census TIGER files` \
    -S 25 `# state fips code (Massachusetts)` \
    -i ma_tracts `# index name` \
    -t tract `# document type`
