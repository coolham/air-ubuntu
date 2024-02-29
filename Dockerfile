FROM ubuntu:22.04

LABEL maintainer "James Ding"
MAINTAINER James Ding "https://github.com/coolham"

ENV POLIPO_VERSION 1.1.1


ENV DEBIAN_FRONTEND=noninteractive
ENV USER=ubuntu \
    PASSWORD=ubuntu \
    UID=1000 \
    GID=1000


ENV VGL_DISPLAY=egl

## Install and Configure OpenGL
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libxau6 libxdmcp6 libxcb1 libxext6 libx11-6 \
        libglvnd0 libgl1 libglx0 libegl1 libgles2 \
        libglvnd-dev libgl1-mesa-dev libegl1-mesa-dev libgles2-mesa-dev && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /usr/share/glvnd/egl_vendor.d/ && \
    echo "{\n\
\"file_format_version\" : \"1.0.0\",\n\
\"ICD\": {\n\
    \"library_path\": \"libEGL_nvidia.so.0\"\n\
}\n\
}" > /usr/share/glvnd/egl_vendor.d/10_nvidia.json



## Install and Configure Vulkan
RUN apt-get update && \
    apt-get install -y --no-install-recommends vulkan-tools && \
    rm -rf /var/lib/apt/lists/* && \
    VULKAN_API_VERSION=$(dpkg -s libvulkan1 | grep -oP 'Version: [0-9|\.]+' | grep -oP '[0-9]+(\.[0-9]+)(\.[0-9]+)') && \
    mkdir -p /etc/vulkan/icd.d/ && \
    echo "{\n\
\"file_format_version\" : \"1.0.0\",\n\
\"ICD\": {\n\
    \"library_path\": \"libGLX_nvidia.so.0\",\n\
        \"api_version\" : \"${VULKAN_API_VERSION}\"\n\
}\n\
}" > /etc/vulkan/icd.d/nvidia_icd


## Install some common tools 
RUN apt-get update  && \
    apt-get install -y ca-certificates sudo vim gedit locales wget curl git lsb-release net-tools iputils-ping mesa-utils proxychains \
                    openssh-server bash-completion software-properties-common unzip python3-pip shadowsocks-libev && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3 2 && \
    pip3 install --upgrade pip &&\
    pip3 install selenium && \
    pip3 install webdriver-manager && \
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
RUN apt-get update -y && apt-get install -y google-chrome-stable &&  update-alternatives --set x-www-browser /usr/bin/google-chrome-stable
#RUN apt-get update -y && apt-get install -y google-chrome-stable 

# 安装依赖工具和Chromedriver所需的软件包


RUN set -xe && apt-get update && apt-get install -y x11vnc tightvncserver


RUN curl -sSLO https://github.com/jech/polipo/archive/polipo-$POLIPO_VERSION.tar.gz \
    && tar -zxf polipo-$POLIPO_VERSION.tar.gz \
    && cd polipo-polipo-$POLIPO_VERSION \
    && make -j${NPROC} \
    && cp polipo /usr/local/bin/polipo \
    && mkdir -p /usr/share/polipo/www /var/cache/polipo \
    && mkdir -p /etc/polipo && cp config.sample /etc/polipo/config.sample

RUN mkdir -p /var/log/polipo


EXPOSE 22 5901 3389


## Copy config
COPY docker_config /docker_config


ENTRYPOINT ["/docker_config/entrypoint.sh"]
