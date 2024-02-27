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


ENV_TMP=.env_tmp

# 动态生成 .env 文件内容
echo "CONTAINER_COUNT=${CONTAINER_COUNT}" > ${ENV_TMP}


# 生成 dynamic_docker-compose.yml 文件
cat <<EOF > dynamic_docker-compose.yml
version: '3'

services:
EOF

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
    env_file: .env_tmp
    volumes:
      - './${HOST_VOLUME_DIR}:/root/.config/google-chrome'
EOF

    # 创建宿主机目录并将卷映射到该目录
    mkdir -p $HOST_VOLUME_DIR
    docker volume create $VOLUME_NAME
done

# 使用 Docker Compose 启动多个实例
#docker-compose -f dynamic_docker-compose.yml up -d --scale wj-airdrop=$CONTAINER_COUNT
docker-compose -f dynamic_docker-compose.yml up -d 

