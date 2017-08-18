FROM base/archlinux

MAINTAINER Matthew Haffner <haffner.matthew.m@gmail.com>

# Install dependencies
RUN pacman -Syu elasticsearch mongodb wget gdal --no-confirm
RUN systemctl enable elasticsearch.service
RUN systemctl start elasticsearch
RUN systemctl start mongodb

# Clone the git repo
RUN git clone https://github.com/mhaffner/shp2nosql ~/shp2nosql
RUN export PATH=$PATH:~/shp2nosql/bin
