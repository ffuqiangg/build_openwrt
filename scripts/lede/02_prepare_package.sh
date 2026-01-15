#!/bin/bash

. ../scripts/functions.sh

### 基础部分 ###
# 使用 O2 级别的优化
sed -i 's/Os/O2/g' include/target.mk
# 更新 Feeds
./scripts/feeds update -a
./scripts/feeds install -a
# 默认开启 Irqbalance
#sed -i "s/enabled '0'/enabled '1'/g" feeds/packages/utils/irqbalance/files/irqbalance.config
# 修复 Rust CI 下载限制
sed -i '/--set=llvm.download-ci-llvm/s/true/false/' feeds/packages/lang/rust/Makefile

### FIREWALL ###
# custom nft command
patch -p1 < ../patch/firewall/100-openwrt-firewall4-add-custom-nft-command-support.patch
# patch LuCI 以支持自定义 nft 规则
pushd feeds/luci
patch -p1 < ../../../patch/firewall/04-luci-add-firewall4-nft-rules-file.patch
popd

### 额外的 LuCI 应用和依赖 ###
mkdir -p ./package/new
# 调整刷机脚本
patch -p1 < ../patch/custom_install/lede/custom_target_amlogic_scripts.patch
mkdir -p ./target/linux/amlogic/mesongx/base-files/usr
mv ./target/linux/amlogic/mesongx/base-files/root ./target/linux/amlogic/mesongx/base-files/usr/sbin
# 调整 default settings
sed -i '/services/d;/exit/d' package/lean/default-settings/files/zzz-default-settings
cat <<-EOF >> package/lean/default-settings/files/zzz-default-settings
sed -i '/BUILD_DATE/d' /etc/openwrt_release
echo "BUILD_DATE='$1'" >> /etc/openwrt_release

exit 0
EOF
# 预编译 node
rm -rf ./feeds/packages/lang/node/*
wget https://raw.githubusercontent.com/sbwml/feeds_packages_lang_node-prebuilt/packages-24.10/Makefile -O feeds/packages/lang/node/Makefile
# 一些补充翻译
echo '
msgid "Custom rules allow you to execute arbitrary nft commands which are not otherwise covered by the firewall framework. The rules are executed after each firewall restart, right after the default ruleset has been loaded."
msgstr "自定义规则允许您执行不属于防火墙框架的任意 nft 命令。每次重启防火墙时，这些命令在默认的规则运行后立即执行。"' >> ./package/lean/default-settings/po/zh-cn/default.po
# mount cgroupv2
pushd feeds/packages
patch -p1 < ../../../patch/cgroupfs-mount/0001-fix-cgroupfs-mount.patch
popd
mkdir -p feeds/packages/utils/cgroupfs-mount/patches
cp -rf ../patch/cgroupfs-mount/900-mount-cgroup-v2-hierarchy-to-sys-fs-cgroup-cgroup2.patch ./feeds/packages/utils/cgroupfs-mount/patches/
cp -rf ../patch/cgroupfs-mount/901-fix-cgroupfs-umount.patch ./feeds/packages/utils/cgroupfs-mount/patches/
cp -rf ../patch/cgroupfs-mount/902-mount-sys-fs-cgroup-systemd-for-docker-systemd-suppo.patch ./feeds/packages/utils/cgroupfs-mount/patches/
# 替换 sing-box
rm -rf ./feeds/packages/net/sing-box
cp -rf ../immortalwrt_pkg_ma/net/sing-box ./feeds/packages/net/sing-box
# v2rayA
rm -rf ./feeds/luci/applications/luci-app-v2raya ./feeds/packages/net/v2raya
cp -rf ../immortalwrt_luci_ma/applications/luci-app-v2raya ./feeds/luci/applications/luci-app-v2raya
cp -rf ../immortalwrt_pkg_ma/net/v2raya ./feeds/packages/net/v2raya
# MosDNS
rm -rf ./feeds/luci/applications/luci-app-mosdns ./feeds/packages/utils/v2dat
rm -rf ./feeds/packages/net/{mosdns,v2ray-geodata}
cp -rf ../openwrt-add/luci-app-mosdns ./package/new/luci-app-mosdns
cp -rf ../v2ray_geodata ./package/new/v2ray-geodata
# Passwall
rm -rf ./feeds/luci/applications/luci-app-passwall
rm -rf ./feeds/packages/net/{chinadns-ng,dns2socks,dns2tcp,geoview,hysteria,microsocks,pdnsd-alt,tcping,trojan,xray-core}
cp -rf ../openwrt-add/openwrt_helloworld ./package/new/
rm -rf ./package/new/openwrt_helloworld/v2ray-geodata
sed -i '/select PACKAGE_geoview/{n;s/default n/default y/;}' package/new/openwrt_helloworld/luci-app-passwall/Makefile
sed -i '/#dde2ff/d;/#2c323c/d' package/new/openwrt_helloworld/luci-app-passwall/luasrc/view/passwall/global/status.htm
# OpenWrt-nikki
rm -rf ./feeds/luci/applications/luci-app-nikki ./feeds/packages/net/nikki
cp -rf ../openwrt-add/OpenWrt-mihomo ./package/new/luci-app-nikki
# OpenWrt-momo
cp -rf ../OpenWrt-momo ./package/new/luci-app-momo
# Cpufreq
#sed -i 's,system,services,g' feeds/luci/applications/luci-app-cpufreq/root/usr/share/luci/menu.d/luci-app-cpufreq.json
# Rclone
sed -i 's,NAS,Services,g;s,nas,services,g' feeds/luci/applications/luci-app-rclone/luasrc/controller/rclone.lua
# Nlbw 带宽监控
sed -i 's,services,network,g' feeds/luci/applications/luci-app-nlbwmon/root/usr/share/luci/menu.d/luci-app-nlbwmon.json
sed -i 's,services,network,g' feeds/luci/applications/luci-app-nlbwmon/htdocs/luci-static/resources/view/nlbw/config.js
# 终端 TTYD
sed -i 's,services,system,g' feeds/luci/applications/luci-app-ttyd/root/usr/share/luci/menu.d/luci-app-ttyd.json
# Docker 容器
rm -rf ./feeds/luci/applications/luci-app-dockerman
cp -rf ../dockerman/applications/luci-app-dockerman ./package/new/luci-app-dockerman
sed -i '/auto_start/d' package/new/luci-app-dockerman/root/etc/uci-defaults/luci-app-dockerman
pushd package/new/luci-app-dockerman
docker_2_services
popd
sed -i '/^start_service/a\\t[ "$(uci -q get dockerd.globals.auto_start)" -eq "0" ] && return 1\n' feeds/packages/utils/dockerd/files/dockerd.init
# Filebrowser 文件管理器
rm -rf ./feeds/luci/applications/luci-app-filebrowser ./feeds/packages/utils/filebrowser
cp -rf ../sbwml_pkg/{luci-app-filebrowser-go,filebrowser} ./package/new/
# Daed
rm -rf ./feeds/packages/net/daed ./feeds/luci/applications/luci-app-daed
cp -rf ../openwrt-add/luci-app-daed ./package/new/
sed -i 's/,runtimefreegc.*//' package/new/luci-app-daed/daed/Makefile
cp -rf ../immortalwrt_pkg_ma/libs/libcron ./package/new/

# 预配置一些插件
sed -i 's,/bin/ash,/bin/bash,' package/base-files/files/etc/passwd
sed -i 's,/bin/ash,/bin/bash,' package/base-files/files/usr/libexec/login.sh
mkdir -p ./files/etc/uci-defaults
cp -rf ../files/{init/*,cpufreq/*} ./files/
cp -f ../patch/default-settings/lede/zzz-default-settings ./files/etc/uci-defaults/
echo -e "\n\033[34mLEDE\033[0m ${2} ${1//./-}\n" > ./files/etc/banner

# 清理临时文件
find ./ -name *.orig | xargs rm -f
find ./ -name *.rej | xargs rm -f

exit 0
