#!/bin/bash

#docker build --build-arg USER_PASSWORD=$(grep ^USER_PASSWORD .env | cut -d '=' -f2) -t wj-airdrop .

set +x
# usage: ./docker_build.sh 20.04-cu11.0

# echo "argv: $1"
UBUNTU_VERSION=`echo $1 | awk -F '-cu' '{print $1}'`
CUDA_VERSION=`echo $1 | awk -F '-cu' '{print $2}'`
#echo "ubuntu version:${UBUNTU_VERSION},cuda version:${CUDA_VERSION}"

UBUNTU_VERSION="22.04"

# check ubuntu version
if [[(${UBUNTU_VERSION} != "20.04") && (${UBUNTU_VERSION} != "22.04")]];then
    echo "Invalid ubuntu version:${UBUNTU_VERSION}"
    exit -1
fi

# pull base image (ubuntu/cuda)
if [[("${CUDA_VERSION}" == "")]];then
    BASE_IMAGE=ubuntu:${UBUNTU_VERSION}
else
    BASE_IMAGE=nvidia/cuda:${CUDA_VERSION}-devel-ubuntu${UBUNTU_VERSION}
fi
echo ${BASE_IMAGE}

docker pull ${BASE_IMAGE}
if [[ $? != 0 ]]; then
    echo "Failed to pull docker image '${BASE_IMAGE}'"
    exit -2
fi

DOCKER_TAG=${UBUNTU_VERSION}

docker build -t wj-airdrop .

if [[ $? != 0 ]]; then
    echo "Failed to build docker image ':${DOCKER_TAG}'"
    exit -3
fi

exit 0

