#!/bin/bash

git clone --depth 1 --single-branch -b openwrt-23.05 https://github.com/openwrt/openwrt.git openwrt &
git clone --depth 1 --single-branch -b master https://github.com/lisaac/luci-app-diskman dockerman &
git clone --depth 1 --single-branch -b master https://github.com/lisaac/luci-lib-docker docker_lib &
git clone --depth 1 --single-branch -b master https://github.com/QiuSimons/openwrt-mos mosdns &
git clone --depth 1 --single-branch -b main https://github.com/Lienol/openwrt-package lienol_pkg &
git clone --depth 1 --single-branch -b main https://github.com/xiaorouji/openwrt-passwall passwall_luci &
git clone --depth 1 --single-branch -b main https://github.com/xiaorouji/openwrt-passwall-packages passwall_pkg &
git clone --depth 1 --single-branch -b master https://github.com/vernesong/OpenClash openclash &
git clone --depth 1 https://github.com/ophub/luci-app-amlogic.git amlogic &
git clone --depth 1 --single-branch -b master https://github.com/coolsnowwolf/luci.git lede_luci

wait

# Modify default IP (FROM 192.168.1.1 CHANGE TO 192.168.1.99 )
sed -i 's/192.168.1.1/192.168.1.99/g' openwrt/package/base-files/files/bin/config_generate

exit 0
