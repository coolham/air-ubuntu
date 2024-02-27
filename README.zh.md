[English](README.md)

本项目旨在在 Docker 容器内运行多个 Ubuntu 实例，每个 Ubuntu 实例都拥有独立的桌面环境。用户可以通过 VNC 或 RDP 协议访问容器内的桌面环境。

项目功能:

在 Docker 容器内运行多个 Ubuntu 实例
每个 Ubuntu 实例拥有独立的桌面环境
支持通过 VNC 或 RDP 协议访问桌面环境
项目优势:

可移植性：项目可移植到任何安装了 Docker 的机器上
可扩展性：项目可扩展，可同时运行多个 Ubuntu 实例
安全性：项目提供安全的环境来运行 Ubuntu 实例
项目应用场景:

为用户提供远程桌面环境
创建软件开发环境
托管 Web 服务器或其他应用程序
项目链接:

GitHub 仓库：https://github.com/
项目文档：https://docs.docker.com/
快速开始:

克隆项目仓库：
git clone https://github.com/username/project.git
进入项目目录：
cd project
构建镜像：
docker build -t ubuntu-desktop .
运行容器：
docker run -it --rm --name ubuntu-desktop ubuntu-desktop
使用 VNC 或 RDP 协议连接到容器：
VNC:

使用 VNC 客户端连接到容器的 IP 地址和端口 5900。
RDP:

使用 RDP 客户端连接到容器的 IP 地址和端口 3389。
注意:

首次运行容器时，可能会需要一些时间来下载 Ubuntu 镜像。
默认情况下，容器的用户名为 ubuntu，密码为 ubuntu。
您可以根据自己的需求修改容器的配置。
联系我们:

如果您有任何问题或建议，请联系我们。

项目贡献:

欢迎您为本项目做出贡献。

捐赠:

如果您觉得本项目对您有所帮助，您可以捐赠以支持项目的发展。

感谢您的支持！
