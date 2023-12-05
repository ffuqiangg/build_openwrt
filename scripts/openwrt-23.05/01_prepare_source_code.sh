#!/bin/bash

clone_repo() {
    repo_url=$1
    branch_name=$2
    target_dir=$3
    git clone -b $branch_name --depth 1 $repo_url $target_dir
}

openwrt_repo="https://github.com/openwrt/openwrt.git"
openwrt_pkg_repo="https://github.com/openwrt/packages.git"
immortalwrt_repo="https://github.com/immortalwrt/immortalwrt.git"
immortalwrt_pkg_repo="https://github.com/immortalwrt/packages.git"
immortalwrt_luci_repo="https://github.com/immortalwrt/luci.git"
lede_repo="https://github.com/coolsnowwolf/lede.git"
lede_luci_repo="https://github.com/coolsnowwolf/luci.git"
lede_pkg_repo="https://github.com/coolsnowwolf/packages.git"
lienol_repo="https://github.com/Lienol/openwrt.git"
lienol_pkg_repo="https://github.com/Lienol/openwrt-package"
openwrt_add_repo="https://github.com/QiuSimons/OpenWrt-Add.git"
passwall_pkg_repo="https://github.com/xiaorouji/openwrt-passwall-packages"
passwall_luci_repo="https://github.com/xiaorouji/openwrt-passwall"
dockerman_repo="https://github.com/lisaac/luci-app-dockerman"
diskman_repo="https://github.com/lisaac/luci-app-diskman"
docker_lib_repo="https://github.com/lisaac/luci-lib-docker"
mosdns_repo="https://github.com/QiuSimons/openwrt-mos"
sirpdboy_repo="https://github.com/sirpdboy/sirpdboy-package"

# 开始克隆仓库，并行执行
clone_repo $openwrt_repo openwrt-23.05 openwrt &
clone_repo $immortalwrt_repo master immortalwrt &
clone_repo $immortalwrt_repo openwrt-21.02 immortalwrt_21 &
clone_repo $immortalwrt_repo openwrt-23.05 immortalwrt_23 &
clone_repo $immortalwrt_pkg_repo master immortalwrt_pkg &
clone_repo $immortalwrt_pkg_repo openwrt-21.02 immortalwrt_pkg_21 &
clone_repo $immortalwrt_luci_repo master immortalwrt_luci &
clone_repo $immortalwrt_luci_repo openwrt-21.02 immortalwrt_luci_21 &
clone_repo $immortalwrt_luci_repo openwrt-23.05 immortalwrt_luci_23 &
clone_repo $lede_repo master lede &
clone_repo $lede_luci_repo master lede_luci &
clone_repo $lede_pkg_repo master lede_pkg &
clone_repo $openwrt_repo main openwrt_ma &
clone_repo $openwrt_repo openwrt-22.03 openwrt_22 &
clone_repo $openwrt_pkg_repo master openwrt_pkg_ma &
clone_repo $lienol_repo 23.05 Lienol &
clone_repo $lienol_pkg_repo main Lienol_pkg &
clone_repo $openwrt_add_repo master OpenWrt-Add &
clone_repo $passwall_pkg_repo main passwall_pkg &
clone_repo $passwall_luci_repo main passwall_luci &
clone_repo $dockerman_repo master dockerman &
clone_repo $diskman_repo master diskman &
clone_repo $docker_lib_repo master docker_lib &
clone_repo $mosdns_repo master mosdns &
clone_repo $sirpdboy_repo main sirpdboy &

wait

# Modify default IP (FROM 192.168.1.1 CHANGE TO 192.168.1.99 )
sed -i 's/192.168.1.1/192.168.1.99/g' openwrt/package/base-files/files/bin/config_generate

exit 0
