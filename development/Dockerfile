FROM centos

MAINTAINER Matthew Haffner <haffner.matthew.m@gmail.com>

# install dependencies
RUN yum group install -y "Development Tools"
RUN yum install -y wget git which gcc java-1.8.0-openjdk

# build gdal from source
RUN wget http://download.osgeo.org/gdal/2.2.1/gdal-2.2.1.tar.gz
RUN tar -xzvf gdal-2.2.1.tar.gz
RUN cd gdal-2.2.1

# create user since elasticsearch cannot be run as root
RUN useradd -ms /bin/bash shp2nosql-user

# create folder for mongodb data
RUN mkdir -p /data/db
RUN chown -R shp2nosql-user /data

USER shp2nosql-user
WORKDIR /home/shp2nosql-user

# download and unpack elasticsearch
RUN wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-5.5.2.tar.gz
RUN tar -xzvf elasticsearch-5.5.2.tar.gz

# download and unpack mongodb
RUN wget https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-3.4.7.tgz
RUN tar -xzvf mongodb-linux-x86_64-3.4.7.tgz

# clone the git repository and export add tool to path
RUN git clone https://github.com/mhaffner/shp2nosql.git

# add/run the startup script (starts elasticsearch and mongodb)
ADD startup.sh /home/shp2nosql-user/startup.sh
ENTRYPOINT bash startup.sh &> out.log; export PATH=$PATH:~/shp2nosql/bin:~/mongodb-linux-x86_64-3.4.7/bin; /bin/bash
