#!/bin/bash

. ./scripts/functions.sh

# 开始克隆仓库，并行执行
git clone -b $1 --depth 1 $openwrt_repo openwrt &
git clone --depth 1 $openwrt_pkg_repo openwrt_pkg_ma &
git clone --depth 1 $immortalwrt_luci_repo immortalwrt_luci_ma &
git clone --depth 1 $immortalwrt_pkg_repo immortalwrt_pkg_ma &
git clone --depth 1 $dockerman_repo dockerman &
git clone --depth 1 $v2ray_geodata_repo v2ray_geodata &
git clone -b openwrt-24.10 --depth 1 $autocore_arm_repo autocore &
git clone --depth 1 $sbwml_pkgs_repo sbwml_pkgs &
git clone --depth 1 $openwrt_add_repo openwrt-add &
git clone --depth 1 $momo_repo OpenWrt-momo &
git clone --depth 1 $amlogic_repo amlogic &
# 等待所有后台任务完成
wait

# 设置默认密码为 password
sed -i 's/root:::0:99999:7:::/root:$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.::0:99999:7:::/g' openwrt/package/base-files/files/etc/shadow
# 修改默认 IP 为 192.168.1.99
#sed -i 's/192.168.1.1/192.168.1.99/g' openwrt/package/base-files/files/bin/config_generate

# 退出脚本
exit 0
