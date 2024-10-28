#!/bin/bash

source ./scripts/funcations.sh

# 开始克隆仓库，并行执行
clone_repo $lede_repo master openwrt &
# 等待所有后台任务完成
wait

# 修改默认 IP ( 192.168.1.1 改为 192.168.1.99 )
sed -i 's/192.168.1.1/192.168.1.99/g' openwrt/package/base-files/files/bin/config_generate

exit 0
