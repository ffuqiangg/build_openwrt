#!/bin/bash

. ./scripts/functions.sh

# 开始克隆仓库，并行执行
clone_repo $immortalwrt_repo openwrt-18.06-k5.4 openwrt &
clone_repo $openwrt_pkg_repo master openwrt_pkg_ma &
clone_repo $mosdns_repo v5.3.1 mosdns &
clone_repo $dockerman_repo master dockerman &
clone_repo $openclash_repo master openclash &
clone_repo $amlogic_repo main amlogic &
clone_repo $openwrt_apps_repo main openwrt-apps &
# 等待所有后台任务完成
wait

# 修改默认 IP 为 192.168.1.99
sed -i 's/192.168.1.1/192.168.1.99/g' openwrt/package/base-files/files/bin/config_generate

exit 0
