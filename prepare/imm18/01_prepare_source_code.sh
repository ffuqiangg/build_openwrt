#!/bin/bash

. ./scripts/functions.sh

# 开始克隆仓库，并行执行
git clone -b openwrt-18.06-k5.4 --depth 1 $immortalwrt_repo openwrt &
git clone --depth 1 $openclash_repo openclash &
git clone --depth 1 $amlogic_repo amlogic &
git clone -b v4 --depth 1 $sbwml_mosdns_repo mosdns &
git clone --depth 1 $v2ray_geodata_repo v2ray_geodata &
git clone -b 18.06 --depth 1 $v2raya_repo v2raya &
# 等待所有后台任务完成
wait

# 修改默认 IP 为 192.168.1.99
#sed -i 's/192.168.1.1/192.168.1.99/g' openwrt/package/base-files/files/bin/config_generate

exit 0
