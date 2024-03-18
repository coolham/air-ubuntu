#!/bin/sh

#docker run -d -p 3389:3389 -p 80:80 -p 443:443 -p 22:22 --name chrome_container -v /path/on/host:/home/user1/.config/google-chrome my_custom_chrome

#docker run -it --rm -p 7389:3389 -p 7022:22 -p 7901:5901 --name wj-airdrop_01 --privileged --memory=1024m --cpu-shares=2 wj-airdrop
#docker run -it --rm -p 7389:3389 -p 7022:22 -p 7901:5901 --name wj-airdrop_01 --security-opt seccomp=unconfined --memory=1024m --cpu-shares=2 wj-airdrop
#docker run -d -e PROXY_TYPE=socks5 -e PROXY_IP=156.226.117.77 -e PROXY_PORT=49262 -e PROXY_USER=uVPPsZE -e PROXY_PASSWORD=mc2EiC  -v ./air_01/google-chrome:/root/.config/google-chrome -p 7389:3389 -p 7022:22 -p 7901:5901 --name wj-airdrop_01 --security-opt seccomp=unconfined --memory=1024m --cpu-shares=2 wj-airdrop


docker run -it --name wj-airdrop-1 --cap-add=SYS_PTRACE --shm-size=1024m --gpus=all -v ./proxy_config/config1:/config -e USER=aladdin  -e PASSWORD=aladdin123  -e GID=1001  -e UID=1001  -p 13022:22 -p 7902:5901 --privileged wj-airdrop

