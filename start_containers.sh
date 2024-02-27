#!/bin/bash

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
docker-compose up -d --scale wj-airdrop=$CONTAINER_COUNT
