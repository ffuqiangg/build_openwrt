#!/bin/bash

. ./scripts/functions.sh

build_date=$(date +%Y.%m.%d)

# 开始克隆仓库，并行执行
git clone --depth 1 $lede_repo openwrt &
git clone --depth 1 $immortalwrt_luci_repo immortalwrt_luci_ma &
git clone --depth 1 $immortalwrt_pkg_repo immortalwrt_pkg_ma &
git clone --depth 1 $dockerman_repo dockerman &
git clone --depth 1 $momo_repo OpenWrt-momo &
git clone --depth 1 $openwrt_add_repo openwrt-add &
git clone --depth 1 $v2ray_geodata_repo v2ray_geodata &
git clone --depth 1 $sbwml_pkgs_repo sbwml_pkg &
# 等待所有后台任务完成
wait

# 修改默认 IP 为 192.168.1.99
sed -i "/lan) ipad=\${ipaddr:-/s/\${ipaddr:-\"[^\"]*\"}/\${ipaddr:-\"192.168.1.99\"}/" openwrt/package/base-files/*/bin/config_generate
# 默认禁用 WIFI
sed -i '/wireless/d' openwrt/package/lean/default-settings/files/zzz-default-settings
sed -Ei "s/(disabled=)0/\11/" openwrt/package/kernel/mac80211/files/lib/wifi/mac80211.sh
# 调整内核版本为 5.15
sed -i 's/KERNEL_PATCHVER:=.*/KERNEL_PATCHVER:=5.15/' openwrt/target/linux/amlogic/Makefile

cat <<EOF | tee -a $GITHUB_ENV
build_date=$build_date
banner_date=${build_date//./-}
distrib_revision=$(grep 'DISTRIB_REVISION=' openwrt/package/lean/default-settings/files/zzz-default-settings | sed -E "s/.*'(.+)'.*/\1/")
EOF

exit 0
