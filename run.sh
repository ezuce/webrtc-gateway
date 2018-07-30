#!/bin/bash 
. ./docker_name.sh
sudo docker run -d -p 7088:7088 -p 7089:7089 -p 8088:8088 -p 8089:8089 -p 30000-31000:30000-31000/udp $DOCKER_IMAGE_NAME -S stun.l.google.com:19302 -e
