#!/bin/bash

set +x

# 检查 .env 文件是否存在
if [ ! -f .env ]; then
    echo "Error: .env file not found. Please create a .env file with necessary configurations."
    exit 1
fi

source .env

# 检查 CONTAINER_COUNT 是否定义
if [ -z "$CONTAINER_COUNT" ]; then
    echo "Error: CONTAINER_COUNT variable is not defined in the .env file."
    exit 1
fi

echo "start n=${CONTAINER_COUNT} instances"

# 读取代理服务器配置文件
PROXY_FILE="proxies.txt"
proxies=()
while IFS=: read -r ip port user password; do
    proxies+=("$ip" "$port" "$user" "$password")
done < "$PROXY_FILE"



# 生成 dynamic_docker-compose.yml 文件
cat <<EOF > dynamic_docker-compose.yml
version: '3'

services:
EOF

proxy_index=0
for ((i=1; i<=$CONTAINER_COUNT; i++))
do
    SERVICE_NAME="wj-airdrop-$(printf %02d $i)"
    VOLUME_NAME="chrome_volume_${i}"
    HOST_VOLUME_DIR="user_volumes/${SERVICE_NAME}"

    cat <<EOF >> dynamic_docker-compose.yml
  $SERVICE_NAME:
    image: 'wj-airdrop'
    privileged: true
    deploy:
      resources:
        limits:
          cpus: "2"
          memory: 2G
    ports:
      - '$((12000 + $i)):22'
      - '$((12100 + $i)):3389'
      - '$((12200 + $i)):5901'
    volumes:
      - './${HOST_VOLUME_DIR}:/root/.config/google-chrome'
    environment:
      - PROXY_TYPE=socks5
      - PROXY_IP=${proxies[$proxy_index]}
      - PROXY_PORT=${proxies[$((proxy_index+1))]}
      - PROXY_USER=${proxies[$((proxy_index+2))]}
      - PROXY_PASSWORD=${proxies[$((proxy_index+3))]}
EOF

    # 创建宿主机目录并将卷映射到该目录
    mkdir -p $HOST_VOLUME_DIR
    docker volume create $VOLUME_NAME

    # 更新代理索引
    proxy_index=$((proxy_index+4))
done

# 使用 Docker Compose 启动多个实例
#docker-compose -f dynamic_docker-compose.yml up -d --scale wj-airdrop=$CONTAINER_COUNT
docker-compose -f dynamic_docker-compose.yml up -d 

