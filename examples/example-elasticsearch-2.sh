shp2es \
    -r `# remove the index if it exists` \
    -f tract `# file to get from US Census TIGER files` \
    -s 25 `# state fips code (Massachusetts)` \
    -i ma_tracts `# index name` \
    -t tract `# document type`
