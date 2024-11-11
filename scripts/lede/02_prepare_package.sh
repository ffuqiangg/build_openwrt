#!/bin/bash

source ../scripts/funcations.sh

### 基础部分 ###
# 使用 O2 级别的优化
sed -i 's/Os/O2/g' include/target.mk
# 更新 Feeds
./scripts/feeds update -a
./scripts/feeds install -a

### FIREWALL ###
# patch LuCI 以支持自定义 nft 规则
pushd feeds/luci
patch -p1 < ../../../patch/firewall/04-luci-add-firewall4-nft-rules-file.patch
popd

### 替换准备 ###
rm -rf feeds/luci/applications/{luci-app-passwall,luci-app-dockerman,luci-app-ttyd}

### 额外的 LuCI 应用和依赖 ###
mkdir -p package/new
# 调整 default settings
sed -i '/services/d' package/lean/default-settings/files/zzz-default-settings
# 预编译 node
rm -rf feeds/packages/lang/node
cp -rf ../node feeds/packages/lang/node
# Passwall
cp -rf ../passwall_luci/luci-app-passwall feeds/luci/applications/luci-app-passwall
# Passwall 白名单
echo '
teamviewer.com
epicgames.com
dangdang.com
account.synology.com
ddns.synology.com
checkip.synology.com
checkip.dyndns.org
checkipv6.synology.com
ntp.aliyun.com
cn.ntp.org.cn
ntp.ntsc.ac.cn
' >> feeds/luci/applications/luci-app-passwall/root/usr/share/passwall/rules/direct_host
# Vsftpd
pushd feeds/luci/applications/luci-app-vsftpd
move_2_services nas
popd
# Cpufreq
sed -i 's,\"system\",\"services\",g' feeds/luci/applications/luci-app-cpufreq/root/usr/share/luci/menu.d/luci-app-cpufreq.json
# Rclone
sed -i -e 's,\"NAS\",\"Services\",g' -e 's,\"nas\",\"services\",g' feeds/luci/applications/luci-app-rclone/luasrc/controller/rclone.lua
# Docker 容器
cp -rf ../dockerman/applications/luci-app-dockerman feeds/luci/applications/luci-app-dockerman
pushd feeds/luci/applications/luci-app-dockerman
docker_2_services
popd
# Verysync
pushd package/feeds/luci/luci-app-verysync
move_2_services nas
popd
# TTYD
cp -rf ../openwrt_luci_ma/applications/luci-app-ttyd feeds/luci/applications/luci-app-ttyd
rm -rf feeds/packages/utils/ttyd
cp -rf ../openwrt_pkg/utils/ttyd feeds/packages/utils/ttyd
# Mihomo
cp -rf ../mihomo ./package/new/mihomo

### 特定优化 ###
sed -i 's,-mcpu=generic,-march=armv8-a+crc+crypto,g' include/target.mk
# 预配置一些插件
mkdir -p files
cp -rf ../files/{etc,root,lede/*,cpufreq/*,sing-box/*} files/
sed -i 's,/bin/ash,/bin/bash,' ./package/base-files/files/etc/passwd && sed -i 's,/bin/ash,/bin/bash,' ./package/base-files/files/usr/libexec/login.sh

find ./ -name *.orig | xargs rm -f
find ./ -name *.rej | xargs rm -f

exit 0
