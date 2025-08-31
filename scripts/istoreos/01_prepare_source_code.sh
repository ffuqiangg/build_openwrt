#!/bin/bash

. ./scripts/functions.sh

# 开始克隆仓库，并行执行
clone_repo $istoreos_repo istoreos-22.03 openwrt &
clone_repo $openwrt_pkg_repo master openwrt_pkg_ma &
clone_repo $immortalwrt_luci_repo openwrt-21.02 immortalwrt_luci_21 &
clone_repo $immortalwrt_pkg_repo openwrt-21.02 immortalwrt_pkg_21 &
clone_repo $node_prebuilt_repo packages-22.03 node &
clone_repo $dockerman_repo master dockerman &
clone_repo $openwrt_apps_repo main openwrt-apps &
# 等待所有后台任务完成
wait

# 修改默认 IP 为 192.168.1.99
sed -i "s/\s'dhcp'//" openwrt/target/linux/amlogic/base-files/etc/board.d/02_network
sed -i 's/192.168.100.1/192.168.1.99/g' openwrt/package/istoreos-files/Makefile
# 修改默认主题为 bootstrap
sed -i -e '/luci-theme-argon/d;75,83d' openwrt/package/istoreos-files/Makefile
sed -i '65,71d' openwrt/package/istoreos-files/files/etc/uci-defaults/09_istoreos
rm openwrt/package/istoreos-files/files/etc/uci-defaults/99_theme

exit 0
