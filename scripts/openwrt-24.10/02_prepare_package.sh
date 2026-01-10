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
sed -i '/--set=llvm.download-ci-llvm/s/true/false/' feeds/packages/lang/rust/Makefile

### FIREWALL ###
# custom nft command
patch -p1 < ../patch/firewall/100-openwrt-firewall4-add-custom-nft-command-support.patch
# patch LuCI 以支持自定义 nft 规则
pushd feeds/luci
patch -p1 < ../../../patch/firewall/04-luci-add-firewall4-nft-rules-file.patch
popd

### 获取额外的 LuCI 应用和依赖 ###
mkdir -p ./package/new
# 一些补充翻译
cp -rf ../patch/addition-trans-zh ./package/new/
# 预编译 node
rm -rf ./feeds/packages/lang/node/*
wget https://raw.githubusercontent.com/sbwml/feeds_packages_lang_node-prebuilt/packages-24.10/Makefile -O feeds/packages/lang/node/Makefile
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
# CPUlimit 占用限制
cp -rf ../immortalwrt_luci_ma/applications/luci-app-cpulimit ./package/new/luci-app-cpulimit
sed -i 's|\.\./\.\.|$(TOPDIR)/feeds/luci|g' package/new/luci-app-cpulimit/Makefile
cp -rf ../immortalwrt_pkg_ma/utils/cpulimit ./package/new/cpulimit
# IP/MAC 绑定
cp -rf ../immortalwrt_luci_ma/applications/luci-app-arpbind ./package/new/luci-app-arpbind
sed -i 's|\.\./\.\.|$(TOPDIR)/feeds/luci|g' package/new/luci-app-arpbind/Makefile
# DDNS scripts aliyun
cp -rf ../sbwml_pkgs/ddns-scripts-aliyun ./package/new/
# Coremark
rm -rf ./feeds/packages/utils/coremark
cp -rf ../sbwml_pkgs/coremark ./feeds/packages/utils/coremark
# Autocore
cp -rf ../autocore ./package/new/autocore
sed -i 's/$(uname -m)/ARMv8 Processor/' package/new/autocore/files/generic/cpuinfo
# 替换 sing-box
rm -rf ./feeds/packages/net/sing-box
cp -rf ../immortalwrt_pkg_ma/net/sing-box ./feeds/packages/net/sing-box 
# MosDNS
rm -rf ./feeds/packages/new/v2ray-geodata
cp -rf ../openwrt-add/luci-app-mosdns ./package/new/luci-app-mosdns
cp -rf ../v2ray_geodata ./package/new/v2ray-geodata
# Passwall
rm -rf ./feeds/packages/net/{xray-core,microsocks}
cp -rf ../openwrt-add/openwrt_helloworld ./package/new/
rm -rf ./package/new/openwrt_helloworld/v2ray-geodata
sed -i '/select PACKAGE_geoview/{n;s/default n/default y/;}' package/new/openwrt_helloworld/luci-app-passwall/Makefile
# v2rayA
rm -rf ./feeds/luci/applications/luci-app-v2raya ./feeds/packages/net/v2raya
cp -rf ../immortalwrt_luci_ma/applications/luci-app-v2raya ./feeds/luci/applications/luci-app-v2raya
cp -rf ../immortalwrt_pkg_ma/net/v2raya ./feeds/packages/net/v2raya
# Zerotier
rm -rf ./feeds/luci/applications/luci-app-zerotier ./feeds/packages/net/zerotier
cp -rf ../immortalwrt_luci_ma/applications/luci-app-zerotier ./feeds/luci/applications/luci-app-zerotier
cp -rf ../immortalwrt_pkg_ma/net/zerotier ./feeds/packages/net/zerotier
# Docker 容器
rm -rf ./feeds/luci/applications/luci-app-dockerman
cp -rf ../dockerman/applications/luci-app-dockerman ./package/new/luci-app-dockerman
sed -i '/auto_start/d' package/new/luci-app-dockerman/root/etc/uci-defaults/luci-app-dockerman
sed -i '/^start_service/a\\t[ "$(uci -q get dockerd.globals.auto_start)" -eq "0" ] && return 1\n' feeds/packages/utils/dockerd/files/dockerd.init
pushd package/new/luci-app-dockerman
docker_to_services
popd
# Filebrowser 文件管理器
cp -rf ../sbwml_pkgs/{luci-app-filebrowser-go,filebrowser} ./package/new/
# KMS 服务器
cp -rf ../sbwml_pkgs/{luci-app-vlmcsd,vlmcsd} ./package/new/
# FTP 服务器
rm -rf ./feeds/packages/net/vsftpd
cp -rf ../sbwml_pkgs/luci-app-vsftpd ./package/new/luci-app-vsftpd
cp -rf ../immortalwrt_pkg_ma/net/vsftpd ./feeds/packages/net/vsftpd
# Nlbw 带宽监控
sed -i 's,services,network,g' package/feeds/luci/luci-app-nlbwmon/root/usr/share/luci/menu.d/luci-app-nlbwmon.json
sed -i 's,services,network,g' package/feeds/luci/luci-app-nlbwmon/htdocs/luci-static/resources/view/nlbw/config.js
# 终端 TTYD
sed -i 's,services,system,g' package/feeds/luci/luci-app-ttyd/root/usr/share/luci/menu.d/luci-app-ttyd.json
# HomeProxy
cp -rf ../openwrt-add/homeproxy ./package/new/luci-app-homeproxy
# OpenWrt-nikki
cp -rf ../openwrt-add/OpenWrt-mihomo ./package/new/luci-app-nikki
# OpenWrt-momo
cp -rf ../OpenWrt-momo ./package/new/luci-app-momo
# Daed
cp -rf ../openwrt-add/luci-app-daed ./package/new/
sed -i 's/,runtimefreegc.*//' package/new/luci-app-daed/daed/Makefile
cp -rf ../immortalwrt_pkg_ma/libs/libcron ./package/new/
# 晶晨宝盒
cp -rf ../amlogic/luci-app-amlogic ./package/new/luci-app-amlogic

# Vermagic
curl -fsSL https://downloads.openwrt.org/releases/${1}/targets/armsr/armv8/profiles.json | jq -r '.linux_kernel.vermagic' > .vermagic
cat .vermagic
sed -i -e 's/^\(.\).*vermagic$/\1cp $(TOPDIR)\/.vermagic $(LINUX_DIR)\/.vermagic/' include/kernel-defaults.mk

### 预配置一些插件 ###
mkdir -p ./files/etc/uci-defaults
cp -rf ../files/init/* ./files/
cp -f ../patch/default-settings/openwrt-24.10/zzz-default-settings ./files/etc/uci-defaults/

# 清理临时文件
find ./ -name *.orig | xargs rm -f
find ./ -name *.rej | xargs rm -f

exit 0
