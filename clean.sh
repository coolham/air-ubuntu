#!/bin/sh

docker rmi $(docker images | grep none | awk '{print $3}')
docker rm $(docker ps -a | grep "wj-airdrop" | awk '{print $1 }')
