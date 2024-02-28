#!/bin/sh

set -x
exec &> /var/log/entrypoint.log

VNC_PASSWORD=root123

## initialize environment
if [ ! -f "/docker_config/init_flag" ]; then
    echo "init new user..."
    # create user
    groupadd -g $GID $USER
    useradd --create-home --no-log-init -u $UID -g $GID $USER
    usermod -aG sudo $USER
    echo "$USER:$PASSWORD" | chpasswd
    chsh -s /bin/bash $USER

    su - $USER -c 'mkdir -p /home/$USER/.vnc && echo "root123" | vncpasswd -f > /home/$USER/.vnc/passwd && chmod 600 /home/$USER/.vnc/passwd'

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
# start sshd&nxserver

echo "start sshd..."
/usr/sbin/sshd
echo "start dbus..."
/etc/init.d/dbus start

export USER=$USER

su - $USER -c "touch /home/$USER/.Xauthority"

echo "start vncserver..."
#vncserver :1 -geometry 1280x800 -depth 24 >> /var/log/tightvnc.log 2>&1 &
su - $USER -c "vncserver :1 -geometry 1280x800 -depth 24 &"

echo "done."

tail -f /dev/null

