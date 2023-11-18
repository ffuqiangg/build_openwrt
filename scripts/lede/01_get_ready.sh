#!/bin/bash

# Clone source code
git clone --single-branch -b master --depth 1 https://github.com/coolsnowwolf/lede openwrt
git clone --single-branch --depth 1 https://github.com/xiaorouji/openwrt-passwall.git passwall_luci
git clone --single-branch --depth 1 https://github.com/xiaorouji/openwrt-passwall-packages.git passwall_pkg
git clone --depth 1 --single-branch -b master https://github.com/vernesong/OpenClash openclash
git clone --single-branch -b main --depth 1 https://github.com/Lienol/openwrt-package.git openwrt_package
git clone --single-branch -b master --depth 1 https://github.com/QiuSimons/openwrt-mos.git mosdns

# Modify default IP (FROM 192.168.1.1 CHANGE TO 192.168.1.99 )
sed -i 's/192.168.1.1/192.168.1.99/g' openwrt/package/base-files/files/bin/config_generate
# Set DISTRIB_REVISION
sed -i "s,DISTRIB_REVISION='.*',DISTRIB_REVISION='R$(date +%y.%m.%d)',g" openwrt/package/lean/default-settings/files/zzz-default-settings

exit 0
