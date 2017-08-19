FROM centos

MAINTAINER Matthew Haffner <haffner.matthew.m@gmail.com>

# install dependencies
RUN yum install -y wget git java-1.8.0-openjdk

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
