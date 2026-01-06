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

### FIREWALL ###
# custom nft command
patch -p1 < ../patch/firewall/100-openwrt-firewall4-add-custom-nft-command-support.patch
# patch LuCI 以支持自定义 nft 规则
pushd feeds/luci
patch -p1 < ../../../patch/firewall/04-luci-add-firewall4-nft-rules-file.patch
popd

### 额外的 LuCI 应用和依赖 ###
rm -rf ./feeds/luci/applications/luci-app-nikki ./feeds/packages/net/nikki
mkdir -p ./package/new
cp -rf ../{OpenWrt-momo,OpenWrt-nikki} ./package/new/
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
rm -rf ./feeds/packages/lang/node
cp -rf ../node ./feeds/packages/lang/node
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
# Passwall
rm -rf ./feeds/luci/applications/luci-app-passwall
rm -rf ./feeds/packages/net/{xray-core,chinadns-ng,dns2socks,microsocks,tcping,geoview}
cp -rf ../passwall_luci/luci-app-passwall ./package/new/luci-app-passwall
cp -rf ../passwall_pkg ./package/new/passwall-packages
rm -rf ./package/new/passwall-packages/{v2ray-geodata,sing-box}
# 替换 sing-box
rm -rf ./feeds/packages/net/sing-box
cp -rf ../immortalwrt_pkg_ma/net/sing-box ./feeds/packages/net/sing-box
# MosDNS
rm -rf ./feeds/luci/applications/luci-app-mosdns ./feeds/packages/utils/v2dat
rm -rf  ./feeds/packages/net/{mosdns,v2ray-geodata}
cp -rf ../mosdns ./package/new/luci-app-mosdns
cp -rf ../mosdns_geodata ./package/new/v2ray-geodata
echo 'account.synology.com
ddns.synology.com
checkip.synology.com
checkip.dyndns.org
checkipv6.synology.com
ntp.aliyun.com
cn.ntp.org.cn
ntp.ntsc.ac.cn' >> package/new/luci-app-mosdns/luci-app-mosdns/root/etc/mosdns/rule/whitelist.txt
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
docker_to_services
popd
# Filebrowser 文件管理器
rm -rf ./feeds/luci/applications/luci-app-filebrowser ./feeds/packages/utils/filebrowser
cp -rf ../sbwml_pkg/{luci-app-filebrowser-go,filebrowser} ./package/new/
# Daed
rm -rf ./feeds/packages/net/daed ./feeds/luci/applications/luci-app-daed
cp -rf ../luci-app-daed ./package/new/
sed -i 's/,runtimefreegc.*//' package/new/luci-app-daed/daed/Makefile
cp -rf ../immortalwrt_pkg_ma/libs/libcron ./package/new/

# 预配置一些插件
sed -i 's,/bin/ash,/bin/bash,' package/base-files/files/etc/passwd
sed -i 's,/bin/ash,/bin/bash,' package/base-files/files/usr/libexec/login.sh
mkdir -p ./files/etc/uci-defaults
cp -rf ../files/{init/*,cpufreq/*} ./files/
cp -f ../patch/default-settings/lede/zzz-default-settings ./files/etc/uci-defaults/

# 清理临时文件
find ./ -name *.orig | xargs rm -f
find ./ -name *.rej | xargs rm -f

exit 0
