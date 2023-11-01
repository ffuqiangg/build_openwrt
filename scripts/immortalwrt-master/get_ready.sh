#!/bin/bash

repo_url="https://github.com/immortalwrt/immortalwrt"
repo_branch="master"

# Clone source code
git clone -q --single-branch --depth=1 -b ${repo_branch} ${repo_url} openwrt
# Add luci-app-amlogic
git clone --depth 1 https://github.com/ophub/luci-app-amlogic.git openwrt/package/luci-app-amlogic
# Add luci-app-mosdns
rm -rf openwrt/feeds/packages/net/v2ray-geodata
git clone --single-branch --depth=1 https://github.com/sbwml/luci-app-mosdns -b v5 openwrt/package/mosdns
git clone https://github.com/sbwml/v2ray-geodata openwrt/package/v2ray-geodata

wait

# Add the default password for the 'root' user（Change the empty password to 'password'）
sed -i 's/root:::0:99999:7:::/root:$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.::0:99999:7:::/g' openwrt/package/base-files/files/etc/shadow
# Modify default IP (FROM 192.168.1.1 CHANGE TO 192.168.1.99 )
sed -i 's/192.168.1.1/192.168.1.99/g' openwrt/package/base-files/files/bin/config_generate

# Set output information
echo "COMPILE_DATE=$(date +%Y%m%d)" >> ${GITHUB_ENV}

cd openwrt
./scripts/feeds update -a
./scripts/feeds install -a
