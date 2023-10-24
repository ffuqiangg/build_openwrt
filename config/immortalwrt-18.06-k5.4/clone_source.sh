#!/bin/bash

REPO_URL="https://github.com/immortalwrt/immortalwrt"
REPO_BRANCH="openwrt-18.06-k5.4"
echo "PACKAGE_REPO=flippy" >> $GITHUB_ENV
echo "MAKE_SH=mk_immortalwrt_18.06_k5.4_n1.sh" >> $GITHUB_ENV
echo "DISTRIB_DES=Immortalwrt" >> $GITHUB_ENV
echo "KERNEL_VERSION=5.4.1" >> $GITHUB_ENV
echo "KERNEL_REPO=ffuqiangg/amlogic-s9xxx-armbian" >> $GITHUB_ENV
echo "COMPILE_DATE=$(date +%Y%m%d)" >> $GITHUB_ENV

# Clone source code
git clone -q --single-branch --depth=1 -b ${REPO_BRANCH} ${REPO_URL} openwrt
ln -sf /workdir/openwrt $GITHUB_WORKSPACE/openwrt
# Set output information
echo "IMAGE_NAME=immortalwrt_18.06_k5.4" >> $GITHUB_ENV
echo -e "REPO_URL: [ ${REPO_URL} ]\nREPO_BRANCH: [ ${REPO_BRANCH} ]"
