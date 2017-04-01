# install prerequisites
sudo add-apt-repository universe # for gdal
sudo add-apt-repository ppa:webupd8team/java # for java
sudo apt-get update
sudo apt-get install git gdal-bin curl oracle-java8-installer vim

# install and start elasticsearch
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
sudo apt-get install apt-transport-https
echo "deb https://artifacts.elastic.co/packages/5.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-5.x.list
sudo apt-get update && sudo apt-get install elasticsearch
# edit /etc/elasticsearch.yml and uncomment cluster.name and node.name
sudo systemctl enable elasticsearch.service
