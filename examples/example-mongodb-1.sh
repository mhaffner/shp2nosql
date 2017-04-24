shp2mongo \
    -r `# remove the database if it exists` \
    -f state `# file to get from US Census TIGER files` \
    -d us_states `# database name` \
    -c state `# collection` \
