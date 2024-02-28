FROM ubuntu:22.04

LABEL maintainer "James Ding"
MAINTAINER James Ding "https://github.com/coolham"

ENV DEBIAN_FRONTEND=noninteractive
ENV USER=ubuntu \
    PASSWORD=ubuntu \
    UID=1000 \
    GID=1000

## Install some common tools 
RUN apt-get update  && \
    apt-get install -y ca-certificates sudo vim gedit locales wget curl git lsb-release net-tools iputils-ping mesa-utils proxychains \
                    openssh-server bash-completion software-properties-common python3-pip  && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3 2 && \
    pip3 install --upgrade pip &&\
    rm -rf /var/lib/apt/lists/* 


## Install desktop
RUN apt-get update && \
    # add apt repo for firefox
    add-apt-repository -y ppa:mozillateam/ppa &&\
    mkdir -p /etc/apt/preferences.d &&\
    echo "Package: firefox*\n\
Pin: release o=LP-PPA-mozillateam\n\
Pin-Priority: 1001" > /etc/apt/preferences.d/mozilla-firefox &&\
    # install xfce4 and firefox
    apt-get install -y xfce4 xfce4-goodies xfce4-terminal terminator fonts-wqy-zenhei xvfb ffmpeg firefox &&\
    # remove and disable screensaver
    apt-get remove -y xfce4-screensaver --purge &&\
    rm -rf /var/lib/apt/lists/*

ENV DBUS_SYSTEM_BUS_ADDRESS=unix:path=/host/run/dbus/system_bus_socket
RUN mkdir -p /var/run/dbus &&\
    rm -rf /var/lib/apt/lists/*

## Configure ssh 
RUN mkdir /var/run/sshd &&  \
    echo 'root:THEPASSWORDYOUCREATED' | chpasswd && \
    sed -i 's/#*PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config && \
    sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd


RUN wget -q -O - http://dl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
#RUN apt-get update -y && apt-get install -y google-chrome-stable &&  update-alternatives --set x-www-browser /usr/bin/google-chrome
RUN apt-get update -y && apt-get install -y google-chrome-stable 


RUN set -xe && apt-get update && apt-get install -y x11vnc tightvncserver

EXPOSE 22 5901 3389


## Copy config
COPY docker_config /docker_config


ENTRYPOINT ["/docker_config/entrypoint.sh"]
