#!/bin/bash

. ./scripts/funcations.sh

# Clone source code
clone_repo $immortalwrt_repo openwrt-18.06-k5.4 openwrt &
clone_repo $immortalwrt_pkg_repo master immortalwrt_pkg &
clone_repo $mosdns_repo v5 mosdns &
clone_repo $v2ray_geodata_repo master v2ray_geodata &

wait

# Modify default IP (FROM 192.168.1.1 CHANGE TO 192.168.1.99 )
sed -i 's/192.168.1.1/192.168.1.99/g' openwrt/package/base-files/files/bin/config_generate

exit 0
