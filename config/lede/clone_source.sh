#!/bin/bash

REPO_URL="https://github.com/coolsnowwolf/lede"
REPO_BRANCH="master"
echo "PACKAGE_REPO=flippy" >> $GITHUB_ENV
echo "MAKE_SH=mk_lede_n1.sh" >> $GITHUB_ENV
echo "DISTRIB_DES=Openwrt" >> $GITHUB_ENV
echo "KERNEL_VERSION=5.15.1" >> $GITHUB_ENV
echo "KERNEL_REPO=breakings/Openwrt" >> $GITHUB_ENV
echo "COMPILE_DATE=R$(date +%y.%m.%d)" >> $GITHUB_ENV

# Clone source code
git clone -q --single-branch --depth=1 -b ${REPO_BRANCH} ${REPO_URL} openwrt
ln -sf /workdir/openwrt $GITHUB_WORKSPACE/openwrt

# Write release.txt
sed -i "s/COMPILE_DATE/$(date +%y.%m.%d)/g" $INIT_SH

# Set output information
echo "IMAGE_NAME=lede" >> $GITHUB_ENV
echo -e "REPO_URL: [ ${REPO_URL} ]\nREPO_BRANCH: [ ${REPO_BRANCH} ]"
