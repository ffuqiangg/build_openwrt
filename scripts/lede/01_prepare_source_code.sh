#!/bin/bash

. ./scripts/functions.sh

# 开始克隆仓库，并行执行
clone_repo $lede_repo master openwrt &
clone_repo $immortalwrt_pkg_repo master immortalwrt_pkg_ma &
clone_repo $dockerman_repo master dockerman &
clone_repo $momo_repo main OpenWrt-momo &
clone_repo $nikki_repo main OpenWrt-nikki &
clone_repo $daed_repo master luci-app-daed &
clone_repo $passwall_luci_repo main passwall_luci &
clone_repo $passwall_pkg_repo main passwall_pkg &
clone_repo $sbwml_mosdns_repo v5 mosdns &
clone_repo $v2ray_geodata_repo master v2ray_geodata &
clone_repo $sbwml_pkgs_repo main sbwml_pkg &
# 等待所有后台任务完成
wait

# 修改默认 IP 为 192.168.1.99
sed -i "/lan) ipad=\${ipaddr:-/s/\${ipaddr:-\"[^\"]*\"}/\${ipaddr:-\"192.168.1.99\"}/" openwrt/package/base-files/*/bin/config_generate
# 默认禁用 WIFI
sed -i '/wireless/d' openwrt/package/lean/default-settings/files/zzz-default-settings
sed -Ei "s/(disabled=)0/\11/" openwrt/package/kernel/mac80211/files/lib/wifi/mac80211.sh
# 调整内核版本为 5.15
sed -i 's/KERNEL_PATCHVER:=.*/KERNEL_PATCHVER:=5.15/' openwrt/target/linux/amlogic/Makefile

exit 0
