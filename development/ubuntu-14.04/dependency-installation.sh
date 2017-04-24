## This is untested

## Install Prerequisites
sudo add-apt-repository ppa:ubuntugis/ubuntugis-unstable # for current version of gdal
sudo add-apt-repository ppa:webupd8team/java # for java
sudo apt-get update
sudo apt-get install git gdal-bin curl oracle-java8-installer vim
cd ~
git clone https://github.com/mhaffner/shp2nosql
PATH=$PATH:~/shp2nosql/bin

## install and start elasticsearch
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
sudo apt-get install apt-transport-https
echo "deb https://artifacts.elastic.co/packages/5.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-5.x.list
sudo apt-get update && sudo apt-get install elasticsearch
## edit /etc/elasticsearch.yml and uncomment cluster.name, node.name, and network.host to 0.0.0.0
sudo service elasticsearch start

## install and start mongodb
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list
sudo apt-get update
sudo apt-get install -y mongodb-org
cp ~/shp2nosql/development/ubuntu-16.04/mongodb.service /etc/systemd/system/mongodb.service
sudo service mongodb start
