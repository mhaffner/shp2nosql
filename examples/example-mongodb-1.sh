shp2nosql \
    -r `# remove the database if it exists` \
    -d mongodb `# database type` \
    -f state `# file to get from US Census TIGER files` \
    -D us_states `# database name` \
    -c state `# collection`
