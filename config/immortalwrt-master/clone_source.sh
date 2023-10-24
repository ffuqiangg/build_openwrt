#!/bin/bash

REPO_URL="https://github.com/immortalwrt/immortalwrt"
REPO_BRANCH="master"
echo "PACKAGE_REPO=ophub" >> $GITHUB_ENV
echo "COMPILE_DATE=$(date +%Y%m%d)" >> $GITHUB_ENV

# Clone source code
git clone -q --single-branch --depth=1 -b ${REPO_BRANCH} ${REPO_URL} openwrt
ln -sf /workdir/openwrt $GITHUB_WORKSPACE/openwrt
# Set output information
echo "IMAGE_NAME=immortalwrt_master" >> $GITHUB_ENV
echo -e "REPO_URL: [ ${REPO_URL} ]\nREPO_BRANCH: [ ${REPO_BRANCH} ]"
