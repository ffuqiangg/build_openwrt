#!/bin/bash

. ./scripts/functions.sh

# 开始克隆仓库，并行执行
clone_repo $lede_repo master openwrt &
clone_repo $dockerman_repo master dockerman &
clone_repo $node_prebuilt_repo packages-24.10 node &
clone_repo $openwrt_apps_repo main openwrt-apps &
# 等待所有后台任务完成
wait

# 修改默认 IP ( 192.168.1.1 改为 192.168.1.99 )
sed -i 's/192.168.1.1/192.168.1.99/g' openwrt/package/base-files/luci2/bin/config_generate
# 调整 LUCI feeds
sed -i '/^src-git luci/s/;.*$/;openwrt-24.10/' openwrt/feeds.conf.default
# 默认禁用 WIFI
sed -Ei "s/(disabled=)0/\11/" openwrt/package/kernel/mac80211/files/lib/wifi/mac80211.sh

exit 0
