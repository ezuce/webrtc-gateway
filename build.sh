#!/bin/bash
. ./arguments.sh
sudo docker build \
--build-arg private_key=$PRIVATE_KEY \
--build-arg public_key=$PUBLIC_KEY \
-t $DOCKER_IMAGE_NAME .
