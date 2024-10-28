#!/bin/bash

source ./scripts/funcations.sh

# 开始克隆仓库，并行执行
clone_repo $lede_repo master openwrt &
clone_repo $immortalwrt_pkg_repo master immortalwrt_pkg &
clone_repo $passwall_pkg_repo main passwall_pkg &
clone_repo $passwall_luci_repo main passwall_luci &
clone_repo $lienol_pkg_repo main lienol_pkg &
clone_repo $mosdns_repo v5 mosdns &
clone_repo $openclash_repo master openclash &
clone_repo $v2ray_geodata_repo master v2ray_geodata &
# 等待所有后台任务完成
wait

# 修改默认 IP ( 192.168.1.1 改为 192.168.1.99 )
sed -i 's/192.168.1.1/192.168.1.99/g' openwrt/package/base-files/files/bin/config_generate

exit 0
