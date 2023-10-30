#!/bin/bash

repo_url="https://github.com/immortalwrt/immortalwrt"
repo_branch="openwrt-18.06-k5.4"


# Clone source code
git clone -q --single-branch --depth=1 -b ${repo_branch} ${repo_url} openwrt
ln -sf /workdir/openwrt ${GITHUB_WORKSPACE}/openwrt

wait

# Some settings
# Modify default IP (FROM 192.168.1.1 CHANGE TO 192.168.1.99 )
sed -i 's/192.168.1.1/192.168.1.99/g' package/base-files/files/bin/config_generate

# Set output information
echo "IMAGE_NAME=immortalwrt_18.06_k5.4" >> ${GITHUB_ENV}
echo "PACKAGE_REPO=flippy" >> ${GITHUB_ENV}
echo "MAKE_SH=mk_immortalwrt_18.06_k5.4_n1.sh" >> ${GITHUB_ENV}
echo "DISTRIB_DES=Immortalwrt" >> ${GITHUB_ENV}
echo "KERNEL_VERSION=5.4.1" >> ${GITHUB_ENV}
echo "KERNEL_REPO=ffuqiangg/amlogic-s9xxx-armbian" >> ${GITHUB_ENV}
echo "COMPILE_DATE=$(date +%Y%m%d)" >> ${GITHUB_ENV}