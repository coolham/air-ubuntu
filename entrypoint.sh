#!/bin/bash

set -x
exec &> /var/log/entrypoint.log


echo "entrypoint.sh start..."
current_time=$(date '+%Y-%m-%d %H:%M:%S')
echo "current time is: $current_time"


export USER=root
export DISPLAY=:1


# 设置信号处理函数
cleanup() {
    # 在这里执行通知桌面环境退出的操作
    echo "Notifying XFCE4 desktop environment to logout..."
    DISPLAY=${DISPLAY} xfce4-session-logout --logout
}

# Set up proxy server variables based on environment variables
echo "socks5 $PROXY_IP $PROXY_PORT $PROXY_USER $PROXY_PASSWORD" > /etc/proxy_tmp
sed -i "s|^socks.*$|$(cat /etc/proxy_tmp)|" /etc/proxychains.conf

# 启动 SSH Server
service ssh start


# 检查是否有旧的 VNC 服务器在运行，并尝试停止它
if pgrep Xtightvnc >/dev/null; then
    echo "Stopping existing VNC server..."
    pkill Xtightvnc
    sleep 2  # 等待一会确保服务器被停止
fi

# 检查是否存在占用的 DISPLAY 端口，并尝试释放
if [ -f /tmp/.X1-lock ]; then
    echo "Display :1 is already in use. Releasing the display."
    rm -f /tmp/.X1-lock
fi

# 删除 X11 套接字文件
rm -f /tmp/.X11-unix/X1

# 将 .Xauthority 文件中的授权信息合并到 X 服务器的授权数据库中
#xauth merge /root/.Xauthority

# 启动 dbus 服务
/etc/init.d/dbus start

# Start X server
#Xorg :0 &
#startxfce4 &
sleep 2  # Add a delay to ensure X server is fully started


#vncserver :1 -geometry 1280x800 -depth 24 &
vncserver :1 -geometry 1280x800 -depth 24 >> /var/log/tightvnc.log 2>&1 &

# output debug info
echo "vnc service started" >> /var/log/x11vnc.log


#service xrdp start


echo "entrypoint.sh complete"

#tail -f /dev/null

# Keep the container running
while true; do
    sleep 1
done
