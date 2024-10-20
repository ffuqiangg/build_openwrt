#!/bin/bash

source ./scripts/funcations.sh

clone_repo $istoreos_repo istoreos-22.03 openwrt &
clone_repo $immortalwrt_pkg_repo master immortalwrt_pkg &
clone_repo $immortalwrt_luci_repo openwrt-23.05 immortalwrt_luci_23 &
clone_repo $immortalwrt_pkg_repo openwrt-21.02 immortalwrt_pkg_21 &
clone_repo $lede_repo master lede &
clone_repo $lede_luci_repo master lede_luci &
clone_repo $openwrt_pkg_repo master openwrt_pkg_ma &
clone_repo $lienol_pkg_repo main lienol_pkg &
clone_repo $diskman_repo master diskman &
clone_repo $mosdns_repo v5 mosdns &
clone_repo $mihomo_repo main mihomo &
clone_repo $node_prebuilt_repo packages-22.03 node &
clone_repo $passwall_pkg_repo main passwall_pkg &
clone_repo $passwall_luci_repo main passwall_luci &
clone_repo $v2ray_geodata_repo master v2ray_geodata &

wait

# 修改默认 IP ( 192.168.1.1 改为 192.168.1.99 )
sed -i 's/192.168.1.1/192.168.1.99/g' openwrt/package/base-files/files/bin/config_generate

exit 0
