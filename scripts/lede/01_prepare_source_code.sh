#!/bin/bash

. ./scripts/funcations.sh

clone_repo $lede_repo master openwrt &
clone_repo $immortalwrt_pkg_repo master immortalwrt_pkg &
clone_repo $passwall_pkg_repo main passwall_pkg &
clone_repo $passwall_luci_repo main passwall_luci &
clone_repo $lienol_pkg_repo main lienol_pkg &
clone_repo $mosdns_repo master mosdns &
clone_repo $openclash_repo master openclash &

wait

# Modify default IP (FROM 192.168.1.1 CHANGE TO 192.168.1.99 )
sed -i 's/192.168.1.1/192.168.1.99/g' openwrt/package/base-files/files/bin/config_generate

exit 0
