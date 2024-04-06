#!/bin/bash

. ./scripts/funcations.sh

latest_release="$(curl -s https://github.com/openwrt/openwrt/tags | grep -Eo "v[0-9\.]+\-*r*c*[0-9]*.tar.gz" | sed -n '/22.03/p' | sed -n 1p | sed 's/.tar.gz//g')"
clone_repo $openwrt_repo $latest_release openwrt_release
clone_repo $istoreos_repo istoreos-22.03 istoreos
clone_repo $openwrt_repo openwrt-22.03 openwrt
rm -f ./openwrt/include/version.mk
rm -f ./openwrt/include/kernel.mk
rm -f ./openwrt/include/kernel-5.10
rm -f ./openwrt/include/kernel-version.mk
rm -f ./openwrt/include/toolchain-build.mk
rm -f ./openwrt/include/kernel-defaults.mk
rm -f ./openwrt/package/base-files/image-config.in
rm -rf ./openwrt/target/linux/*
rm -rf ./openwrt/package/kernel/linux/*
cp -f ./openwrt_release/include/version.mk ./openwrt/include/version.mk
cp -f ./openwrt_release/include/kernel.mk ./openwrt/include/kernel.mk
cp -f ./openwrt_release/include/kernel-5.10 ./openwrt/include/kernel-5.10
cp -f ./openwrt_release/include/kernel-version.mk ./openwrt/include/kernel-version.mk
cp -f ./openwrt_release/include/toolchain-build.mk ./openwrt/include/toolchain-build.mk
cp -f ./openwrt_release/include/kernel-defaults.mk ./openwrt/include/kernel-defaults.mk
cp -f ./openwrt_release/package/base-files/image-config.in ./openwrt/package/base-files/image-config.in
cp -f ./openwrt_release/version ./openwrt/version
cp -f ./openwrt_release/version.date ./openwrt/version.date
cp -rf ./istoreos/target/linux/* ./openwrt/target/linux/
cp -rf ./istoreos/package/kernel/linux/* ./openwrt/package/kernel/linux/

# 开始克隆仓库，并行执行
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
clone_repo $lucidaednext_repo rebase lucidaednext &
clone_repo $node_prebuilt_repo packages-23.05 node &
clone_repo $openclash_repo master openclash &
clone_repo $sbwml_openwrt_repo v5 sbwml &
clone_repo $openwrt_node master openwrt-node &
clone_repo $ssrp_repo master ssrp &

wait

# Add the default password for the 'root' user（Change the empty password to 'password'）
sed -i 's/root:::0:99999:7:::/root:$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.::0:99999:7:::/g' openwrt/package/base-files/files/etc/shadow
# Modify default IP (FROM 192.168.1.1 CHANGE TO 192.168.1.99 )
sed -i 's/192.168.1.1/192.168.1.99/g' openwrt/package/base-files/files/bin/config_generate

exit 0
