#!/bin/bash

. ./scripts/functions.sh

# 开始克隆仓库，并行执行
clone_repo $openwrt_repo ${1} openwrt &
clone_repo $openwrt_pkg_repo master openwrt_pkg_ma &
clone_repo $dockerman_repo master dockerman &
clone_repo $node_prebuilt_repo packages-24.10 node &
clone_repo $openwrt_apps_repo main openwrt-apps &
clone_repo $amlogic_repo main amlogic &
# 等待所有后台任务完成
wait

# 设置默认密码为 password
sed -i 's/root:::0:99999:7:::/root:$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.::0:99999:7:::/g' openwrt/package/base-files/files/etc/shadow
# 修改默认 IP 为 192.168.1.99
sed -i 's/192.168.1.1/192.168.1.99/g' openwrt/package/base-files/files/bin/config_generate

# 退出脚本
exit 0
