#!/bin/bash

# Clone source code
git clone --single-branch -b openwrt-18.06-k5.4 --depth 1 https://github.com/immortalwrt/immortalwrt openwrt &
git clone --single-branch -b master --depth 1 https://github.com/QiuSimons/openwrt-mos.git mosdns &
git clone -b main --depth 1 https://github.com/sirpdboy/sirpdboy-package sirpdboy &

wait

# Modify default IP (FROM 192.168.1.1 CHANGE TO 192.168.1.99 )
sed -i 's/192.168.1.1/192.168.1.99/g' openwrt/package/base-files/files/bin/config_generate

exit 0
