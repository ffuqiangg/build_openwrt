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
# 修复 Rust CI 下载限制
sed -i 's/--set=llvm\.download-ci-llvm=true/--set=llvm.download-ci-llvm=false/' feeds/packages/lang/rust/Makefile

### FIREWALL ###
# custom nft command
patch -p1 < ../patch/firewall/100-openwrt-firewall4-add-custom-nft-command-support.patch
# patch LuCI 以支持自定义 nft 规则
pushd feeds/luci
patch -p1 < ../../../patch/firewall/04-luci-add-firewall4-nft-rules-file.patch
popd

### 替换准备 ###
rm -rf ./feeds/packages/net/{v2ray-geodata,mosdns,sing-box}

### 额外的 LuCI 应用和依赖 ###
mkdir -p ./package/new
cp -rf ../openwrt-apps/{OpenWrt-nikki,OpenWrt-momo} ./package/new/
# 添加翻译
cp -rf ../openwrt-apps/addition-trans-zh ./package/new/addition-trans-zh
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
# sing-box
cp -rf ../openwrt-apps/openwrt_helloworld/sing-box ./package/new/sing-box
# Mosdns
cp -rf ../openwrt-apps/luci-app-mosdns ./package/new/luci-app-mosdns
cp -rf ../openwrt-apps/openwrt_helloworld/v2ray-geodata ./package/new/v2ray-geodata
# Samba4
sed -i 's,nas,services,g' feeds/luci/applications/luci-app-samba4/root/usr/share/luci/menu.d/luci-app-samba4.json
# Cpufreq
sed -i 's,system,services,g' feeds/luci/applications/luci-app-cpufreq/root/usr/share/luci/menu.d/luci-app-cpufreq.json
# 硬盘休眠
sed -i 's,nas,services,g' feeds/luci/applications/luci-app-hd-idle/root/usr/share/luci/menu.d/luci-app-hd-idle.json
# FTP 服务器
pushd feeds/luci/applications/luci-app-vsftpd
move_2_services nas
popd
# Rclone
sed -i 's,nas,services,g;s,NAS,Services,g' feeds/luci/applications/luci-app-rclone/luasrc/controller/rclone.lua
# Docker 容器
sed -i '/auto_start/d' feeds/luci/applications/luci-app-dockerman/root/etc/uci-defaults/luci-app-dockerman
pushd feeds/luci/applications/luci-app-dockerman
docker_2_services
popd
# Nlbw 带宽监控
sed -i 's,services,network,g' feeds/luci/applications/luci-app-nlbwmon/root/usr/share/luci/menu.d/luci-app-nlbwmon.json
sed -i 's,services,network,g' feeds/luci/applications/luci-app-nlbwmon/htdocs/luci-static/resources/view/nlbw/config.js
# 晶晨宝盒
cp -rf ../amlogic/luci-app-amlogic ./package/new/luci-app-amlogic

# Vermagic
curl -fsSL https://downloads.immortalwrt.org/releases/${1}/targets/armsr/armv8/profiles.json | jq -r '.linux_kernel.vermagic' > .vermagic
cat .vermagic
sed -i -e 's/^\(.\).*vermagic$/\1cp $(TOPDIR)\/.vermagic $(LINUX_DIR)\/.vermagic/' include/kernel-defaults.mk

# 预配置一些插件
mkdir -p ./files/etc/uci-defaults
cp -rf ../files/init/* ./files/
cp -f ../patch/default-settings/immortalwrt-24.10/zzz-default-settings ./files/etc/uci-defaults/

# 清理临时文件
find ./ -name *.orig | xargs rm -f
find ./ -name *.rej | xargs rm -f

exit 0
