sudo pacman -Syu git elasticsearch mongodb wget gdal
sudo systemctl enable elasticsearch.service
sudo systemctl start elasticsearch
sudo systemctl start mongodb
