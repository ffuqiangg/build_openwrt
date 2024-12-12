#!/bin/bash

. ./scripts/functions.sh

# 开始克隆仓库，并行执行
latest_release="$(curl -s https://github.com/openwrt/openwrt/tags | grep -Eo "v[0-9\.]+-*r*c*[0-9]*.tar.gz" | sed -n '/23.05/p' | sed -n 1p | sed 's/.tar.gz//g')"
clone_repo $openwrt_repo $latest_release openwrt &
clone_repo $immortalwrt_luci_repo openwrt-23.05 immortalwrt_luci_23 &
clone_repo $immortalwrt_pkg_repo openwrt-23.05 immortalwrt_pkg_23 &
clone_repo $openwrt_repo openwrt-23.05 openwrt_snap &
clone_repo $openwrt_pkg_repo master openwrt_pkg_ma &
clone_repo $dockerman_repo master dockerman &
clone_repo $node_prebuilt_repo packages-23.05 node &
clone_repo $openwrt_apps_repo main openwrt-apps &
clone_repo $amlogic_repo main amlogic &
# 等待所有后台任务完成
wait

# 进行一些处理
find openwrt/package/* -maxdepth 0 ! -name 'firmware' ! -name 'kernel' ! -name 'base-files' ! -name 'Makefile' -exec rm -rf {} +
rm -rf ./openwrt_snap/package/firmware ./openwrt_snap/package/kernel ./openwrt_snap/package/base-files ./openwrt_snap/package/Makefile
cp -rf ./openwrt_snap/package/* ./openwrt/package/
cp -rf ./openwrt_snap/feeds.conf.default ./openwrt/feeds.conf.default

# 设置默认密码为 password
sed -i 's/root:::0:99999:7:::/root:$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.::0:99999:7:::/g' openwrt/package/base-files/files/etc/shadow
# 修改默认 IP 为 192.168.1.99
sed -i 's/192.168.1.1/192.168.1.99/g' openwrt/package/base-files/files/bin/config_generate

# 退出脚本
exit 0
