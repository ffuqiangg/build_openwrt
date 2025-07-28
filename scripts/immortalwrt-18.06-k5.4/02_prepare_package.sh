#!/bin/bash

. ../scripts/functions.sh

### 基础部分 ###
# 使用 O2 级别的优化
sed -i 's/Os/O2/g' include/target.mk
# 更新 Feeds
./scripts/feeds update -a
./scripts/feeds install -a

### 额外的 LuCI 应用和依赖 ###
mkdir -p ./package/new
# 调整 default settings
rm -f ./package/emortal/default-settings/files/openwrt_banner
sed -i '/settings\/install/{n;N;N;d}' package/emortal/default-settings/Makefile
# MosDNS
cp -rf ../mosdns/luci-app-mosdns ./package/new/luci-app-mosdns
# Mosdns 白名单
echo 'account.synology.com
ddns.synology.com
checkip.synology.com
checkip.dyndns.org
checkipv6.synology.com
ntp.aliyun.com
cn.ntp.org.cn
ntp.ntsc.ac.cn' >> package/new/luci-app-mosdns/root/etc/mosdns/rule/whitelist.txt
rm -rf ./feeds/packages/net/v2ray-geodata
cp -rf ../v2ray_geodata ./feeds/packages/net/v2ray-geodata
# Samba4
sed -i 's,\"nas\",\"services\",g' feeds/luci/applications/luci-app-samba4/luasrc/controller/samba4.lua
# Cpufreq
sed -i 's,\"system\",\"services\",g' feeds/luci/applications/luci-app-cpufreq/luasrc/controller/cpufreq.lua
# HD-idle
sed -i 's,\"nas\",\"services\",g' feeds/luci/applications/luci-app-hd-idle/luasrc/controller/hd_idle.lua
# Vsftpd
sed -i 's,\"nas\",\"services\",g;s,NAS,Services,g' feeds/luci/applications/luci-app-vsftpd/luasrc/controller/vsftpd.lua
# Filebrowser 文件浏览器
sed -i "s,PKG_VERSION:=.*,PKG_VERSION:=2\.32\.0," feeds/packages/utils/filebrowser/Makefile
sed -i "s,PKG_MIRROR_HASH:=.*,PKG_MIRROR_HASH:=61e9de6b2d396614f45be477e5bb5aad189e7bb1155a3f88800e02421bd6cc2b," feeds/packages/utils/filebrowser/Makefile
sed -i 's,nas,services,g;s,NAS,Services,g' feeds/luci/applications/luci-app-filebrowser/luasrc/controller/filebrowser.lua
sed -i 's,nas,services,g' feeds/luci/applications/luci-app-filebrowser/luasrc/view/filebrowser/filebrowser_status.htm
# Rclone
sed -i 's,\"nas\",\"services\",g;s,NAS,Services,g' feeds/luci/applications/luci-app-rclone/luasrc/controller/rclone.lua
# Docker 容器
sed -i '/auto_start/d' feeds/luci/applications/luci-app-dockerman/root/etc/uci-defaults/luci-app-dockerman
pushd package/feeds/luci/luci-app-dockerman
docker_2_services
popd
# OpenClash
rm -rf ./feeds/luci/applications/luci-app-openclash
cp -rf ../openclash/luci-app-openclash ./feeds/luci/applications/luci-app-openclash
# nlbw
sed -i 's|admin\",|& \"network\",|g;s,admin/,&network/,g' feeds/luci/applications/luci-app-nlbwmon/luasrc/controller/nlbw.lua
sed -i 's,admin/,&network/,g' feeds/luci/applications/luci-app-nlbwmon/luasrc/model/cbi/nlbw/config.lua
sed -i 's,admin/,&network/,g' feeds/luci/applications/luci-app-nlbwmon/luasrc/view/nlbw/backup.htm
sed -i 's,admin/,&network/,g' feeds/luci/applications/luci-app-nlbwmon/luasrc/view/nlbw/display.htm
# V2raya
clone_repo https://github.com/zxlhhyccc/luci-app-v2raya.git 18.06 package/new/luci-app-v2raya
# 晶晨宝盒
cp -rf ../amlogic/luci-app-amlogic ./package/new/luci-app-amlogic

# 预配置一些插件
mkdir -p ./files
cp -rf ../files/init/* ./files/
mkdir -p ./files/etc/uci-defaults
cp -f ../patch/default-settings/immortalwrt-18.06/zzz-default-settings ./files/etc/uci-defaults/
mkdir -p ./files/etc/openclash/core
wget -qO- https://github.com/vernesong/OpenClash/raw/core/master/meta/clash-linux-arm64.tar.gz | tar xOvz > files/etc/openclash/core/clash_meta
chmod +x files/etc/openclash/core/clash*
mkdir -p ./files/usr/bin
wget -q https://github.com/filebrowser/filebrowser/releases/latest/download/linux-arm64-filebrowser.tar.gz | tar xOvz filebrowser > files/usr/bin/filebrowser
chmod +x files/usr/bin/filebrowser

# 清理临时文件
find ./ -name *.orig | xargs rm -f
find ./ -name *.rej | xargs rm -f

exit 0
