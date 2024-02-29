#!/bin/bash

set -x
exec &> /var/log/entrypoint.log
chmod o+w /var/log/entrypoint.log

VNC_PASSWORD=root123


# 设置信号处理函数
cleanup() {
    # 在这里执行通知桌面环境退出的操作
    echo "Notifying XFCE4 desktop environment to logout..."
    DISPLAY=${DISPLAY} xfce4-session-logout --logout
}


## initialize environment
if [ ! -f "/docker_config/init_flag" ]; then
    echo "init new user..."
    # create user
    groupadd -g $GID $USER
    useradd --create-home --no-log-init -u $UID -g $GID $USER
    usermod -aG sudo $USER
    echo "$USER:$PASSWORD" | chpasswd
    chsh -s /bin/bash $USER

    
    # Change ownership and permissions of mounted directory
    chown -R $USER:$USER /home/$USER

    su - $USER -c 'mkdir -p ~/.local/share/applications'

    # Add custom Chrome shortcut for the user
    su - $USER -c 'cat <<EOF > ~/.local/share/applications/chrome.desktop
[Desktop Entry]
Version=1.0
Name=Google Chrome Airdrop
Comment=Access the Internet with Google Chrome
Exec=/usr/bin/google-chrome-stable --restore-last-session --disable-gpu
Icon=google-chrome
Terminal=false
Type=Application
Categories=Network;WebBrowser;
EOF'
    chmod +x /home/$USER/.local/share/applications/chrome.desktop


    #su - $USER -c 'mkdir -p /home/$USER/.vnc && echo "root123" | vncpasswd -f > /home/$USER/.vnc/passwd && chmod 600 /home/$USER/.vnc/passwd'
    su - $USER -c "mkdir -p /home/$USER/.vnc && echo 'root123' | vncpasswd -f > /home/$USER/.vnc/passwd && chmod 600 /home/$USER/.vnc/passwd"

    # extra env init for developer
    if [ -f "/docker_config/env_init.sh" ]; then
        bash /docker_config/env_init.sh
    fi
    # custom env init for user
    if [ -f "/docker_config/custom_env_init.sh" ]; then
        bash /docker_config/custom_env_init.sh
    fi
    echo  "ok" > /docker_config/init_flag
fi
## startup
# custom startup for user
if [ -f "/docker_config/custom_startup.sh" ]; then
	bash /docker_config/custom_startup.sh
fi


# Set up proxy server variables based on environment variables
echo "socks5 $PROXY_IP $PROXY_PORT $PROXY_USER $PROXY_PASSWORD" > /etc/proxy_tmp
sed -i "s|^socks.*$|$(cat /etc/proxy_tmp)|" /etc/proxychains.conf



# Start ss-local
ss-local -c /config/ss-config.json &

# Start Polipo
polipo -c /config/polipo-config &


# start sshd&nxserver
echo "start sshd..."
/usr/sbin/sshd



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


echo "start dbus..."
/etc/init.d/dbus start

# Change ownership and permissions of mounted directory
chown -R $USER:$USER /home/$USER

su - $USER -c "touch /home/$USER/.Xauthority"

echo "start vncserver..."
#vncserver :1 -geometry 1280x800 -depth 24 >> /var/log/tightvnc.log 2>&1 &
su - $USER -c "vncserver :1 -geometry 1280x800 -depth 24 &"

echo "done."

tail -f /dev/null

# Keep the container running
#while true; do
#    sleep 1
#done
     
