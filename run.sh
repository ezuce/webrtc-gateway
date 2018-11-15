#!/bin/bash
. ./arguments.sh
sudo docker run -d --restart=unless-stopped -v $PATH_DOMAIN:/opt/janus/share/janus/certs -p 7088:7088 -p 7089:7089 -p 8088:8088 -p 8089:8089 -p 30000-31000:30000-31000/udp $DOCKER_IMAGE_NAME -S stun.l.google.com:19302 -e
