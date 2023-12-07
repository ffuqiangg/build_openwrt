#!/bin/bash

clone_repo() {
    repo_url=$1
    branch_name=$2
    target_dir=$3
    git clone -b $branch_name --depth 1 $repo_url $target_dir
}

lede_repo="https://github.com/coolsnowwolf/lede.git"
passwall_pkg_repo="https://github.com/xiaorouji/openwrt-passwall-packages"
passwall_luci_repo="https://github.com/xiaorouji/openwrt-passwall"
lienol_pkg_repo="https://github.com/Lienol/openwrt-package"
openwrt_add_repo="https://github.com/QiuSimons/OpenWrt-Add.git"
mosdns_repo="https://github.com/QiuSimons/openwrt-mos"
sirpdboy_repo="https://github.com/sirpdboy/sirpdboy-package"
openclash_repo="https://github.com/vernesong/OpenClash"
openwrt_pkg_repo="https://github.com/openwrt/packages.git

clone_repo $lede_repo master openwrt &
clone_repo $passwall_pkg_repo main passwall_pkg &
clone_repo $passwall_luci_repo main passwall_luci &
clone_repo $lienol_pkg_repo main Lienol_pkg &
clone_repo $mosdns_repo master mosdns &
clone_repo $sirpdboy_repo main sirpdboy &
clone_repi $openclash_repo master openclash &
clone_repo $openwrt_pkg_repo master openwrt_pkg_ma &

wait

# Modify default IP (FROM 192.168.1.1 CHANGE TO 192.168.1.99 )
sed -i 's/192.168.1.1/192.168.1.99/g' openwrt/package/base-files/files/bin/config_generate

exit 0
