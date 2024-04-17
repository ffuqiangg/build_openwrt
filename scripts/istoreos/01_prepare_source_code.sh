#!/bin/bash

. ./scripts/funcations.sh

# 开始克隆仓库，并行执行
clone_repo https://github.com/istoreos/istoreos.git istoreos-22.03 openwrt &
# clone_repo $immortalwrt_repo master immortalwrt &
# clone_repo $immortalwrt_repo openwrt-21.02 immortalwrt_21 &
# clone_repo $immortalwrt_repo openwrt-23.05 immortalwrt_23 &
# clone_repo $immortalwrt_pkg_repo master immortalwrt_pkg &
# clone_repo $immortalwrt_pkg_repo openwrt-21.02 immortalwrt_pkg_21 &
# clone_repo $immortalwrt_luci_repo master immortalwrt_luci &
# clone_repo $immortalwrt_luci_repo openwrt-21.02 immortalwrt_luci_21 &
# clone_repo $immortalwrt_luci_repo openwrt-23.05 immortalwrt_luci_23 &
# clone_repo $lede_repo master lede &
# clone_repo $lede_luci_repo master lede_luci &
# clone_repo $lede_pkg_repo master lede_pkg &
# clone_repo $openwrt_repo main openwrt_ma &
# clone_repo $openwrt_repo openwrt-22.03 openwrt_22 &
clone_repo $openwrt_pkg_repo master openwrt_pkg_ma &
# clone_repo $lienol_repo 23.05 Lienol &
clone_repo $lienol_pkg_repo main Lienol_pkg &
# clone_repo $openwrt_add_repo master OpenWrt-Add &
# clone_repo $passwall_pkg_repo main passwall_pkg &
# clone_repo $passwall_luci_repo main passwall_luci &
clone_repo $dockerman_repo master dockerman &
clone_repo $diskman_repo master diskman &
# clone_repo $docker_lib_repo master docker_lib &
clone_repo $mosdns_repo v5 mosdns &
# clone_repo $lucidaednext_repo rebase lucidaednext &
clone_repo $node_prebuilt_repo packages-22.03 node &
clone_repo $openclash_repo master openclash &
# clone_repo $sbwml_openwrt_repo v5 sbwml &

wait

# Add the default password for the 'root' user（Change the empty password to 'password'）
sed -i 's/root:::0:99999:7:::/root:$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.::0:99999:7:::/g' openwrt/package/base-files/files/etc/shadow
# Modify default IP (FROM 192.168.1.1 CHANGE TO 192.168.1.99 )
sed -i 's/192.168.1.1/192.168.1.99/g' openwrt/package/base-files/files/bin/config_generate

exit 0
