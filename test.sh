script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd ../ && pwd )"
script_dir="$( cd "$( dirname `which shp2nosql` )" && cd ../ && pwd )"
echo $script_dir
