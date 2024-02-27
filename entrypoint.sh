#!/bin/bash

set -x
exec &> /var/log/entrypoint.log

export USER=root
export DISPLAY=:0

# 启动 SSH Server
service ssh start

# for debug
#tail -f /dev/null

# 将 .Xauthority 文件中的授权信息合并到 X 服务器的授权数据库中
xauth merge /root/.Xauthority

# Start X server
#Xorg :0 &
startx &
sleep 2  # Add a delay to ensure X server is fully started

# 启动 x11vnc 服务
#x11vnc -storepasswd root123 /etc/vnc/vncpasswd
#x11vnc -forever -rfbauth /etc/vnc/vncpasswd >> /var/log/x11vnc.log 2>&1 &

pkill Xtightvnc

#vncserver :1 -geometry 1280x800 -depth 24 &
vncserver :1 -geometry 1280x800 -depth 24 >> /var/log/tightvnc.log 2>&1 &

# output debug info
echo "vnc service started" >> /var/log/x11vnc.log

# 保持容器运行
#tail -f /dev/null

# 保持容器运行
#exec "$@"

service xrdp start

# Keep the container running
trap "exit 0" SIGINT SIGTERM
while true; do sleep 1; done


