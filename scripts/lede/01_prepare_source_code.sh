#!/bin/bash

source ./scripts/funcations.sh

# 开始克隆仓库，并行执行
clone_repo $lede_repo master openwrt &
clone_repo $mihomo_repo main mihomo &
# 等待所有后台任务完成
wait

# 修改默认 IP ( 192.168.1.1 改为 192.168.1.99 )
sed -i 's/192.168.1.1/192.168.1.99/g' openwrt/package/base-files/luci2/bin/config_generate
# 修改 mmcblk1p3 分区大小
sed -i 's/2812/1788/' openwrt/target/linux/amlogic/mesongx/base-files/usr/sbin/install-to-emmc.sh

exit 0
