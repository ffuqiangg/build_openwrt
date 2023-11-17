#!/bin/bash

# Clone source code
git clone --single-branch -b openwrt-23.05 --depth 1 https://github.com/immortalwrt/immortalwrt.git openwrt
git clone --single-branch -b openwrt-22.03 --depth 1 https://github.com/openwrt/openwrt.git openwrt_22
git clone --depth 1 https://github.com/ophub/luci-app-amlogic.git amlogic
git clone --single-branch -b master --depth 1 https://github.com/QiuSimons/openwrt-mos.git mosdns

wait

# Add the default password for the 'root' user（Change the empty password to 'password'）
sed -i 's/root:::0:99999:7:::/root:$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.::0:99999:7:::/g' openwrt/package/base-files/files/etc/shadow
# Modify default IP (FROM 192.168.1.1 CHANGE TO 192.168.1.99 )
sed -i 's/192.168.1.1/192.168.1.99/g' openwrt/package/base-files/files/bin/config_generate

exit 0
