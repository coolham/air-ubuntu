FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:0

ARG USER_PASSWORD

ARG PROXY_TYPE
ARG PROXY_IP
ARG PROXY_PORT
ARG PROXY_USER
ARG PROXY_PASSWORD

# 设置 VNC 密码
ENV VNC_PW=$USER_PASSWORD


# 安装 X Window 相关软件
#RUN set -xe && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y xorg openbox
RUN set -xe && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y xserver-xorg-core openbox

RUN set -xe && apt-get install -y net-tools vim
#RUN set -xe && apt-get install -y supervisor openssh-server x11vnc xfce4 xfce4-goodies xfce4-terminal paper-icon-theme tightvncserver xvfb
RUN set -xe && apt-get install -y supervisor openssh-server x11vnc xfce4 xfce4-goodies xfce4-terminal paper-icon-theme tightvncserver
#RUN set -xe && apt-get install -y gdm3 dbus-x11 x11-xserver-utils xubuntu-desktop xfonts-base
RUN set -xe && apt-get install -y dbus dbus-x11 x11-xserver-utils xubuntu-desktop xfonts-base
RUN set -xe && apt-get install -y python3 bash curl 
RUN set -xe && apt-get install -y dnsutils proxychains
RUN set -xe && apt-get install -y xrdp

#RUN set -xe && apt-get install -y nvidia-driver-545-open 

RUN update-alternatives --set x-session-manager /usr/bin/xfce4-session

RUN adduser xrdp ssl-cert

RUN apt-get install -y locales && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8
   
ENV USER=root

ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    HOME=/root

ENV DISPLAY=:1 

# 允许 root 用户通过 SSH 登录
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config


# 设置 root 用户密码
RUN echo 'root:'$USER_PASSWORD | chpasswd

# 将 Xauthority 文件添加到容器镜像中
COPY config/Xauthority /root/.Xauthority

# 设置 Xauthority 文件权限
RUN chmod 600 /root/.Xauthority



COPY config/vnc/xstartup  /root/.vnc/xstartup

RUN chmod +x  /root/.vnc/xstartup

# 创建初始密码文件
RUN mkdir -p /root/.vnc && echo $VNC_PW | vncpasswd -f > /root/.vnc/passwd && chmod 600 /root/.vnc/passwd

# chinese fonts 
RUN apt-get install -y ttf-wqy-microhei && \
    apt-get install -y ttf-wqy-zenhei && \
    apt-get install -y xfonts-wqy


# 添加 Google Chrome 的 APT 源
#RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | gpg --dearmor > /usr/share/keyrings/google-chrome-archive-keyring.gpg
#RUN echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome-archive-keyring.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list

RUN wget -q -O - http://dl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
RUN apt-get update -y && apt-get install -y google-chrome-stable
RUN apt-get install -y gnome-terminal


# 创建 Chrome 无沙盒模式快捷方式
RUN echo "[Desktop Entry]\n\
Name=Google Chrome (No Sandbox)\n\
Comment=Access the Internet\n\
Exec=google-chrome --no-sandbox %U\n\
Terminal=false\n\
Type=Application\n\
Icon=google-chrome\n\
Categories=Network;WebBrowser;" > /usr/share/applications/chrome.desktop

# 更新应用程序菜单
RUN update-desktop-database /usr/share/applications


# proxychains
RUN sed -i 's/socks4 127.0.0.1 9050/socks5 $PROXY_IP $PROXY_PORT $PROXY_USER $PROXY_PASSWORD/g' /etc/proxychains.conf

# 创建用户 aladdin，并将其添加到 sudo 组
RUN useradd -ms /bin/bash aladdin && \
    usermod -aG sudo aladdin

# 设置密码
RUN echo 'aladdin:$USER_PASSWORD' | chpasswd


COPY config/vnc/xstartup  /home/aladdin/.vnc/xstartup

RUN chmod +x  /home/aladdin/.vnc/xstartup

# 创建初始密码文件
RUN mkdir -p /home/aladdin/.vnc && echo $VNC_PW | vncpasswd -f > /home/aladdin/.vnc/passwd && chmod 600 /home/aladdin/.vnc/passwd
RUN chown -R aladdin:aladdin /home/aladdin/.vnc

# 切换到 aladdin 用户
#USER aladdin
#WORKDIR /home/aladdin



COPY extensions /root/extensions
# 加载Chrome扩展
#RUN google-chrome-stable --load-extension=/home/aladdin/extensions


# 映射 Chrome 数据目录到宿主机目录
VOLUME ["/root/.config/google-chrome"]

# 复制 entrypoint.sh 到容器中
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

EXPOSE 22

ENTRYPOINT ["/entrypoint.sh"]

