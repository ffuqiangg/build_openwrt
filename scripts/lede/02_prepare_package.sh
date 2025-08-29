#!/bin/bash

. ../scripts/functions.sh

### 基础部分 ###
# 使用 O2 级别的优化
sed -i 's/Os/O2/g' include/target.mk
# 更新 Feeds
./scripts/feeds update -a
./scripts/feeds install -a
# 默认开启 Irqbalance
sed -i "s/enabled '0'/enabled '1'/g" feeds/packages/utils/irqbalance/files/irqbalance.config

### FIREWALL ###
# custom nft command
patch -p1 < ../patch/firewall/100-openwrt-firewall4-add-custom-nft-command-support.patch
# patch LuCI 以支持自定义 nft 规则
pushd feeds/luci
patch -p1 < ../../../patch/firewall/04-luci-add-firewall4-nft-rules-file.patch
popd

### 额外的 LuCI 应用和依赖 ###
mkdir -p ./package/new
cp -rf ../openwrt-apps/{OpenWrt-nikki,OpenWrt-momo} ./package/new/
cp -rf ../openwrt-apps/openwrt_pkgs/{filebrowser,luci-app-filebrowser-go} ./package/new/
# 调整刷机脚本
patch -p1 < ../patch/custom_install/lede/custom_target_amlogic_scripts.patch
# 调整 default settings
sed -i '/services/d' package/lean/default-settings/files/zzz-default-settings
# 预编译 node
rm -rf ./feeds/packages/lang/node
cp -rf ../node ./feeds/packages/lang/node
# 添加翻译
echo '
msgid "Custom rules allow you to execute arbitrary nft commands which are not otherwise covered by the firewall framework. The rules are executed after each firewall restart, right after the default ruleset has been loaded."
msgstr "自定义规则允许您执行不属于防火墙框架的任意 nft 命令。每次重启防火墙时，这些命令在默认的规则运行后立即执行。"' >> ./package/lean/default-settings/po/zh-cn/default.po
# Passwall
rm -rf ./feeds/luci/applications/luci-app-passwall
cp -rf ../openwrt-apps/openwrt_helloworld/luci-app-passwall ./feeds/luci/applications/luci-app-passwall
# 替换 sing-box
rm -rf ./feeds/packages/net/sing-box
cp -rf ../openwrt-apps/openwrt_helloworld/sing-box ./feeds/packages/net/sing-box
# FTP 服务器
pushd feeds/luci/applications/luci-app-vsftpd
move_2_services nas
popd
# Mosdns 白名单
echo 'account.synology.com
ddns.synology.com
checkip.synology.com
checkip.dyndns.org
checkipv6.synology.com
ntp.aliyun.com
cn.ntp.org.cn
ntp.ntsc.ac.cn' >> feeds/luci/applications/luci-app-mosdns/root/etc/mosdns/rule/whitelist.txt
# Cpufreq
sed -i 's,\"system\",\"services\",g' feeds/luci/applications/luci-app-cpufreq/root/usr/share/luci/menu.d/luci-app-cpufreq.json
# Samba4
sed -i 's,nas,services,g' feeds/luci/applications/luci-app-samba4/root/usr/share/luci/menu.d/luci-app-samba4.json
# 硬盘休眠
sed -i 's,nas,services,g' feeds/luci/applications/luci-app-hd-idle/root/usr/share/luci/menu.d/luci-app-hd-idle.json
# Rclone
sed -i 's,\"NAS\",\"Services\",g;s,\"nas\",\"services\",g' feeds/luci/applications/luci-app-rclone/luasrc/controller/rclone.lua
# Nlbw 带宽监控
sed -i 's,services,network,g' feeds/luci/applications/luci-app-nlbwmon/root/usr/share/luci/menu.d/luci-app-nlbwmon.json
sed -i 's,services,network,g' feeds/luci/applications/luci-app-nlbwmon/htdocs/luci-static/resources/view/nlbw/config.js
# 终端 TTYD
sed -i 's,services,system,g' feeds/luci/applications/luci-app-ttyd/root/usr/share/luci/menu.d/luci-app-ttyd.json
# Docker 容器
rm -rf ./feeds/luci/applications/luci-app-dockerman
cp -rf ../dockerman/applications/luci-app-dockerman ./feeds/luci/applications/luci-app-dockerman
sed -i '/auto_start/d' feeds/luci/applications/luci-app-dockerman/root/etc/uci-defaults/luci-app-dockerman
pushd feeds/luci/applications/luci-app-dockerman
docker_2_services
popd

# 生成默认配置及缓存
rm -rf .config
sed -i 's,/bin/ash,/bin/bash,' package/base-files/files/etc/passwd
sed -i 's,/bin/ash,/bin/bash,' package/base-files/files/usr/libexec/login.sh

# 预配置一些插件
mkdir -p ./files/etc/uci-defaults
cp -rf ../files/{init/*,cpufreq/*} ./files/
cp -f ../patch/default-settings/lede/zzz-default-settings ./files/etc/uci-defaults/

# 清理临时文件
find ./ -name *.orig | xargs rm -f
find ./ -name *.rej | xargs rm -f

exit 0
