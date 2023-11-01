#!/bin/bash

repo_url="https://github.com/immortalwrt/immortalwrt"
repo_branch="openwrt-18.06-k5.4"


# Clone source code
git clone -q --single-branch --depth=1 -b ${repo_branch} ${repo_url} openwrt
# Add luci-app-mosdns
rm -rf openwrt/feeds/packages/net/v2ray-geodata
git clone --depth=1 --single-branch -b v5 https://github.com/sbwml/luci-app-mosdns openwrt/package/mosdns
git clone https://github.com/sbwml/v2ray-geodata openwrt/package/v2ray-geodata

wait

# Modify default IP (FROM 192.168.1.1 CHANGE TO 192.168.1.99 )
sed -i 's/192.168.1.1/192.168.1.99/g' openwrt/package/base-files/files/bin/config_generate

# Set output information
echo "COMPILE_DATE=$(date +%Y%m%d)" >> ${GITHUB_ENV}

cd openwrt
./scripts/feeds update -a
./scripts/feeds install -a
