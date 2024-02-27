#!/bin/bash

set -x
exec &> /var/log/entrypoint.log

export USER=root

# 启动 SSH Server
service ssh start

# for debug
#tail -f /dev/null

# 将 .Xauthority 文件中的授权信息合并到 X 服务器的授权数据库中
xauth merge /root/.Xauthority


Xvfb :1 -screen 0 1024x768x16 &   # 启动虚拟 X Server
export DISPLAY=:1                 # 设置显示变量

dbus-daemon --system                # 启动 D-Bus system bus
/etc/init.d/dbus start


# Start X server
#Xorg :0 &
startxfce4 &
#startx &
sleep 2  # Add a delay to ensure X server is fully started

# 启动 x11vnc 服务
#x11vnc -storepasswd root123 /etc/vnc/vncpasswd
#x11vnc -forever -rfbauth /etc/vnc/vncpasswd >> /var/log/x11vnc.log 2>&1 &

#pkill Xtightvnc

#vncserver :1 -geometry 1280x800 -depth 24 &
vncserver :1 -geometry 1280x800 -depth 24 >> /var/log/tightvnc.log 2>&1 &


#service xrdp start

# Keep the container running
#trap "exit 0" SIGINT SIGTERM
#while true; do sleep 1; done

# 设置 X server 访问权限
xhost +local:docker


tail -f /dev/null                   # 防止容器退出

