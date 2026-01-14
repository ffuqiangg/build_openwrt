#!/bin/bash

. ./scripts/functions.sh

build_date=$(date +%Y.%m.%d)

# 开始克隆仓库，并行执行
git clone -b istoreos-22.03 --depth 1 $istoreos_repo openwrt &
git clone --depth 1 $openwrt_pkg_repo openwrt_pkg_ma &
git clone -b openwrt-21.02 --depth 1 $immortalwrt_luci_repo immortalwrt_luci_21 &
git clone -b openwrt-21.02 --depth 1 $immortalwrt_pkg_repo immortalwrt_pkg_21 &
git clone --depth 1 $immortalwrt_luci_repo immortalwrt_luci_ma &
git clone --depth 1 $immortalwrt_pkg_repo immortalwrt_pkg_ma &
git clone --depth 1 $lede_luci_repo lede_luci_ma &
git clone --depth 1 $dockerman_repo dockerman &
git clone --depth 1 $sbwml_pkgs_repo sbwml_pkgs &
git clone --depth 1 $v2raya_repo v2raya &
git clone --depth 1 $openwrt_add_repo openwrt-add &
git clone --depth 1 $v2ray_geodata_repo v2ray_geodata &
git clone -b openwrt-22.03 --depth 1 $autocore_arm_repo autocore &
# 等待所有后台任务完成
wait

# 修改默认 IP 为 192.168.1.99
sed -i "s/\s'dhcp'//" openwrt/target/linux/amlogic/base-files/etc/board.d/02_network
sed -i 's/192.168.100.1/192.168.1.99/g' openwrt/package/istoreos-files/Makefile
# 修改默认主题为 bootstrap
sed -i -e '/luci-theme-argon/d;75,83d' openwrt/package/istoreos-files/Makefile
rm ./openwrt/package/istoreos-files/files/etc/uci-defaults/99_theme

cat <<EOF | tee -a $GITHUB_ENV
build_date=$build_date
banner_date=${build_date//./-}
EOF

exit 0
