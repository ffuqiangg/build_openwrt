#!/bin/bash

# Clone source code
git clone -q --single-branch --depth=1 -b master https://github.com/immortalwrt/immortalwrt openwrt

cd openwrt

# Add luci-app-amlogic
git clone --depth 1 https://github.com/ophub/luci-app-amlogic.git package/luci-app-amlogic
# Add luci-app-mosdns
rm -rf feeds/packages/net/v2ray-geodata
git clone --single-branch --depth=1 https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns
git clone https://github.com/sbwml/v2ray-geodata package/v2ray-geodata

wait

# Add the default password for the 'root' user（Change the empty password to 'password'）
sed -i 's/root:::0:99999:7:::/root:$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.::0:99999:7:::/g' package/base-files/files/etc/shadow
# Modify default IP (FROM 192.168.1.1 CHANGE TO 192.168.1.99 )
sed -i 's/192.168.1.1/192.168.1.99/g' package/base-files/files/bin/config_generate

# Set output information
echo "COMPILE_DATE=$(date +%Y%m%d)" >> ${GITHUB_ENV}

./scripts/feeds update -a
./scripts/feeds install -a
