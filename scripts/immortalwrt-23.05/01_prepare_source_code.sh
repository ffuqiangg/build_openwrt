#!/bin/bash

source ./scripts/funcations.sh

# Clone source code
latest_release="$(curl -s https://github.com/immortalwrt/immortalwrt/tags | grep -Eo "v[0-9\.]+-*r*c*[0-9]*.tar.gz" | sed -n '/23.05/p' | sed -n 1p | sed 's/.tar.gz//g')"
clone_repo $immortalwrt_repo ${latest_release} openwrt &
clone_repo $openwrt_pkg_repo master openwrt_pkg_ma &
clone_repo $lede_pkg_repo master lede_pkg &
clone_repo $mosdns_repo v5 mosdns &
clone_repo $mihomo_repo main mihomo &
clone_repo $v2ray_geodata_repo master v2ray_geodata &
clone_repo $node_prebuilt_repo packages-23.05 node &
# 等待所有后台任务完成
wait

# 设置默认密码为 password
sed -i 's/root:::0:99999:7:::/root:$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.::0:99999:7:::/g' openwrt/package/base-files/files/etc/shadow
# 修改默认 IP 为 192.168.1.99
sed -i 's/192.168.1.1/192.168.1.99/g' openwrt/package/base-files/files/bin/config_generate

exit 0
