#!/bin/sh

docker build --build-arg USER_PASSWORD=$(grep ^USER_PASSWORD .env | cut -d '=' -f2) -t wj-airdrop .
