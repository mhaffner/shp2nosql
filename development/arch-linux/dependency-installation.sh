sudo pacman -Syu elasticsearch mongodb wget gdal vim
sudo systemctl enable elasticsearch.service
sudo systemctl start elasticsearch
sudo systemctl start mongodb
export PATH=$PATH:~/git-repos/shp2nosql/bin
