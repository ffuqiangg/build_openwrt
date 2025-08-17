#!/bin/bash

. ../scripts/functions.sh

### 基础部分 ###
# 使用 O2 级别的优化
sed -i 's/Os/O2/g' include/target.mk
# 更新 Feeds
./scripts/feeds update -a
./scripts/feeds install -a
# vermagic
sed -i '/CONFIG_BUILDBOT/d' include/feeds.mk
sed -i 's/;)\s*\\/; \\/' include/feeds.mk

### FIREWALL ###
# custom nft command
patch -p1 < ../patch/firewall/100-openwrt-firewall4-add-custom-nft-command-support.patch
# patch LuCI 以支持自定义 nft 规则
pushd feeds/luci
patch -p1 < ../../../patch/firewall/04-luci-add-firewall4-nft-rules-file.patch
popd

### 替换准备 ###
cp -rf ../openwrt-apps ./package/new
rm -rf ./package/new/{luci-app-frpc,luci-app-frps,imm_pkg/frp}
rm -rf ./feeds/packages/net/{xray-core,v2ray-core,v2ray-geodata,sing-box,microsocks,shadowsocks-libev,zerotier,daed,v2raya}
rm -rf ./feeds/luci/applications/{luci-app-zerotier,luci-app-v2raya,luci-app-dockerman}
rm -rf ./feeds/packages/utils/coremark

### 获取额外的 LuCI 应用和依赖 ###
# 预编译 node
rm -rf ./feeds/packages/lang/node
cp -rf ../node ./feeds/packages/lang/node
# 更换 golang 版本
rm -rf ./feeds/packages/lang/golang
cp -rf ../openwrt_pkg_ma/lang/golang ./feeds/packages/lang/golang
# mount cgroupv2
pushd feeds/packages
patch -p1 < ../../../patch/cgroupfs-mount/0001-fix-cgroupfs-mount.patch
popd
mkdir -p ./feeds/packages/utils/cgroupfs-mount/patches
cp -rf ../patch/cgroupfs-mount/900-mount-cgroup-v2-hierarchy-to-sys-fs-cgroup-cgroup2.patch ./feeds/packages/utils/cgroupfs-mount/patches/
cp -rf ../patch/cgroupfs-mount/901-fix-cgroupfs-umount.patch ./feeds/packages/utils/cgroupfs-mount/patches/
cp -rf ../patch/cgroupfs-mount/902-mount-sys-fs-cgroup-systemd-for-docker-systemd-suppo.patch ./feeds/packages/utils/cgroupfs-mount/patches/
# Docker 容器
cp -rf ../dockerman/applications/luci-app-dockerman ./feeds/luci/applications/luci-app-dockerman
sed -i '/auto_start/d' feeds/luci/applications/luci-app-dockerman/root/etc/uci-defaults/luci-app-dockerman
pushd feeds/luci/applications/luci-app-dockerman
docker_2_services
popd
# Nlbw 带宽监控
sed -i 's,services,network,g' package/feeds/luci/luci-app-nlbwmon/root/usr/share/luci/menu.d/luci-app-nlbwmon.json
sed -i 's,services,network,g' package/feeds/luci/luci-app-nlbwmon/htdocs/luci-static/resources/view/nlbw/config.js
# 终端 TTYD
sed -i 's,services,system,g' package/feeds/luci/luci-app-ttyd/root/usr/share/luci/menu.d/luci-app-ttyd.json
# 晶晨宝盒
cp -rf ../amlogic/luci-app-amlogic ./package/new/luci-app-amlogic

# Vermagic
wget https://downloads.openwrt.org/releases/${1}/targets/armsr/armv8/profiles.json
jq -r '.linux_kernel.vermagic' profiles.json > .vermagic
cat .vermagic
sed -i -e 's/^\(.\).*vermagic$/\1cp $(TOPDIR)\/.vermagic $(LINUX_DIR)\/.vermagic/' include/kernel-defaults.mk

### 预配置一些插件 ###
mkdir -p ./files
cp -rf ../files/init/* ./files/
mkdir -p ./files/etc/uci-defaults
cp -f ../patch/default-settings/openwrt-24.10/zzz-default-settings ./files/etc/uci-defaults/

# 清理临时文件
find ./ -name *.orig | xargs rm -f
find ./ -name *.rej | xargs rm -f

exit 0
