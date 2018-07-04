#!/bin/bash 
. ./docker_name.sh
sudo docker run -itd --env MY_IP=206.190.144.30 --name ezuce_webrtc_gateway -p 8089:8089 -p 8088:8088 -p 30000-31000:30000-31000/udp $DOCKER_IMAGE_NAME
