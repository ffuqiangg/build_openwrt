#!/bin/bash

# Clone source code
git clone --single-branch -b openwrt-23.05 --depth 1 https://github.com/immortalwrt/immortalwrt openwrt

cd openwrt
./scripts/feeds update -a
./scripts/feeds install -a

# Add luci-app-amlogic
git clone --depth 1 https://github.com/ophub/luci-app-amlogic.git package/luci-app-amlogic
# Add luci-app-mosdns
# rm -rf feeds/packages/net/v2ray-geodata
# git clone --single-branch -b v5 --depth 1 https://github.com/sbwml/luci-app-mosdns package/mosdns
# git clone https://github.com/sbwml/v2ray-geodata package/v2ray-geodata

# Add the default password for the 'root' user（Change the empty password to 'password'）
sed -i 's/root:::0:99999:7:::/root:$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.::0:99999:7:::/g' package/base-files/files/etc/shadow
# Modify default IP (FROM 192.168.1.1 CHANGE TO 192.168.1.99 )
sed -i 's/192.168.1.1/192.168.1.99/g' package/base-files/files/bin/config_generate
