#!/bin/bash

# Clone source code
git clone -q --single-branch --depth=1 -b openwrt-18.06-k5.4 https://github.com/immortalwrt/immortalwrt openwrt

cd openwrt

# Add luci-app-mosdns
rm -rf feeds/packages/net/v2ray-geodata
git clone --depth=1 --single-branch -b v5 https://github.com/sbwml/luci-app-mosdns package/mosdns
git clone https://github.com/sbwml/v2ray-geodata package/v2ray-geodata

wait

# Modify default IP (FROM 192.168.1.1 CHANGE TO 192.168.1.99 )
sed -i 's/192.168.1.1/192.168.1.99/g' package/base-files/files/bin/config_generate

./scripts/feeds update -a
./scripts/feeds install -a
