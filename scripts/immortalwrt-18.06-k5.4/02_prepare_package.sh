#!/bin/bash

. ../scripts/funcations.sh

### 基础部分 ###
# 使用 O2 级别的优化
sed -i 's/Os/O2/g' include/target.mk
# 更新 Feeds
./scripts/feeds update -a
./scripts/feeds install -a

### 额外的 LuCI 应用和依赖 ###
mkdir -p package/new
# 调整 default settings
patch -p1 < ../patch/default-settings/immortalwrt-18.06/default-settings_add_custom_command.patch
# MosDNS
cp -rf ../mosdns ./package/new/luci-app-mosdns
# Mosdns 白名单
echo 'account.synology.com
ddns.synology.com
checkip.synology.com
checkip.dyndns.org
checkipv6.synology.com
ntp.aliyun.com
cn.ntp.org.cn
ntp.ntsc.ac.cn' >> package/new/luci-app-mosdns/luci-app-mosdns/root/etc/mosdns/rule/whitelist.txt
rm -rf feeds/packages/net/v2ray-geodata
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
sed -i "s,PKG_VERSION:=.*,PKG_VERSION:=2\.31\.2," feeds/packages/utils/filebrowser/Makefile
sed -i "s,PKG_MIRROR_HASH:=.*,PKG_MIRROR_HASH:=bfda9ea7c44d4cb93c47a007c98b84f853874e043049b44eff11ca00157d8426," feeds/packages/utils/filebrowser/Makefile
sed -i 's,\"nas\",\"services\",g;s,NAS,Services,g' feeds/luci/applications/luci-app-filebrowser/luasrc/controller/filebrowser.lua
sed -i 's,nas,services,g' feeds/luci/applications/luci-app-filebrowser/luasrc/view/filebrowser/filebrowser_status.htm
# Rclone
sed -i 's,\"nas\",\"services\",g;s,NAS,Services,g' feeds/luci/applications/luci-app-rclone/luasrc/controller/rclone.lua
# Docker 容器
rm -rf ./feeds/luci/applications/luci-app-dockerman
cp -rf ../dockerman/applications/luci-app-dockerman ./feeds/luci/applications/luci-app-dockerman
sed -i '/auto_start/d' feeds/luci/applications/luci-app-dockerman/root/etc/uci-defaults/luci-app-dockerman
pushd package/feeds/luci/luci-app-dockerman
docker_2_services
popd
# nlbw
sed -i 's|admin\",|& \"network\",|g;s,admin/,&network/,g' feeds/luci/applications/luci-app-nlbwmon/luasrc/controller/nlbw.lua
sed -i 's,admin/,&network/,g' feeds/luci/applications/luci-app-nlbwmon/luasrc/model/cbi/nlbw/config.lua
sed -i 's,admin/,&network/,g' feeds/luci/applications/luci-app-nlbwmon/luasrc/view/nlbw/backup.htm
sed -i 's,admin/,&network/,g' feeds/luci/applications/luci-app-nlbwmon/luasrc/view/nlbw/display.htm
# V2raya
git clone -b 18.06 --depth 1 https://github.com/zxlhhyccc/luci-app-v2raya.git package/new/luci-app-v2raya
# Verysync
pushd feeds/luci/applications/luci-app-verysync
move_2_services nas
popd

# Vermagic
echo 'f61e6059e4d2da5a44b60b362de89967' > .vermagic
sed -i -e 's/^\(.\).*vermagic$/\1cp $(TOPDIR)\/.vermagic $(LINUX_DIR)\/.vermagic/' include/kernel-defaults.mk

# 预配置一些插件
mkdir -p files/etc/openclash/core
cp -rf ../files/{etc,root,/cpufreq/*} files/
clash_version="$(curl -fsSL https://github.com/vernesong/OpenClash/raw/core/master/core_version | sed -n '2p')"
wget -qO- https://github.com/vernesong/OpenClash/raw/core/master/premium/clash-linux-arm64-${clash_version}.gz | gunzip -c > files/etc/openclash/core/clash_tun
wget -qO- https://github.com/vernesong/OpenClash/raw/core/master/meta/clash-linux-arm64.tar.gz | tar xOvz > files/etc/openclash/core/clash_meta
wget -qO- https://github.com/vernesong/OpenClash/raw/core/master/dev/clash-linux-arm64.tar.gz | tar xOvz > files/etc/openclash/core/clash
chmod +x files/etc/openclash/core/clash*

find ./ -name *.orig | xargs rm -f
find ./ -name *.rej | xargs rm -f

exit 0
