#!/bin/bash

source ../scripts/funcations.sh

### 基础部分 ###
# 使用 O2 级别的优化
sed -i 's/Os/O2/g' include/target.mk
# 更新 Feeds
./scripts/feeds update -a
./scripts/feeds install -a

### 替换准备 ###
rm -rf feeds/packages/net/{v2ray-geodata,v2raya}

### 额外的 LuCI 应用和依赖 ###
mkdir -p package/new
# 修改 banner
rm ./package/emortal/default-settings/files/openwrt_banner
sed -i '/openwrt_banner/d' ./package/emortal/default-settings/files/99-default-settings
sed -i '/etc$/,+2d' ./package/emortal/default-settings/Makefile
# MosDNS
cp -rf ../mosdns ./package/new/luci-app-mosdns
cp -rf ../v2ray_geodata package/new/v2ray-geodata
# Samba4
sed -i 's,\"nas\",\"services\",g' feeds/luci/applications/luci-app-samba4/luasrc/controller/samba4.lua
# Cpufreq
sed -i 's,\"system\",\"services\",g' feeds/luci/applications/luci-app-cpufreq/luasrc/controller/cpufreq.lua
# HD-idle
sed -i 's,\"nas\",\"services\",g' feeds/luci/applications/luci-app-hd-idle/luasrc/controller/hd_idle.lua
# Vsftpd
sed -i -e 's,\"nas\",\"services\",g' -e 's,NAS,Services,g' feeds/luci/applications/luci-app-vsftpd/luasrc/controller/vsftpd.lua
# Filebrowser
sed -i "s,PKG_VERSION:=.*,PKG_VERSION:=2\.31\.2," feeds/packages/utils/filebrowser/Makefile
sed -i "s,PKG_MIRROR_HASH:=.*,PKG_MIRROR_HASH:=bfda9ea7c44d4cb93c47a007c98b84f853874e043049b44eff11ca00157d8426," feeds/packages/utils/filebrowser/Makefile
sed -i -e 's,\"nas\",\"services\",g' -e 's,NAS,Services,g' feeds/luci/applications/luci-app-filebrowser/luasrc/controller/filebrowser.lua
sed -i 's,nas,services,g' feeds/luci/applications/luci-app-filebrowser/luasrc/view/filebrowser/filebrowser_status.htm
# Rclone
sed -i -e 's,\"nas\",\"services\",g' -e 's,NAS,Services,g' feeds/luci/applications/luci-app-rclone/luasrc/controller/rclone.lua
# Dockerman
pushd package/feeds/luci/luci-app-dockerman
docker_2_services
popd
# nlbw
sed -i -e 's|admin\",|& \"network\",|g' -e 's,admin/,&network/,g' feeds/luci/applications/luci-app-nlbwmon/luasrc/controller/nlbw.lua
sed -i 's,admin/,&network/,g' feeds/luci/applications/luci-app-nlbwmon/luasrc/model/cbi/nlbw/config.lua
sed -i 's,admin/,&network/,g' feeds/luci/applications/luci-app-nlbwmon/luasrc/view/nlbw/backup.htm
sed -i 's,admin/,&network/,g' feeds/luci/applications/luci-app-nlbwmon/luasrc/view/nlbw/display.htm
# V2raya
git clone -b 18.06 --depth 1 https://github.com/zxlhhyccc/luci-app-v2raya.git package/new/luci-app-v2raya
cp -rf ../immortalwrt_pkg/net/v2raya ./feeds/packages/net/v2raya
# Verysync
pushd feeds/luci/applications/luci-app-verysync
move_2_services nas
popd

# 预配置一些插件
cp -rf ../patch/files ./files
mkdir -p files/etc/openclash/core
clash_version="$(curl -fsSL https://github.com/vernesong/OpenClash/raw/core/master/core_version | sed -n '2p')"
wget -qO- https://github.com/vernesong/OpenClash/raw/core/master/premium/clash-linux-arm64-${clash_version}.gz | gunzip -c > files/etc/openclash/core/clash_tun
wget -qO- https://github.com/vernesong/OpenClash/raw/core/master/meta/clash-linux-arm64.tar.gz | tar xOvz > files/etc/openclash/core/clash_meta
wget -qO- https://github.com/vernesong/OpenClash/raw/core/master/dev/clash-linux-arm64.tar.gz | tar xOvz > files/etc/openclash/core/clash
chmod +x files/etc/openclash/core/clash*
wget -qO- https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat > files/etc/openclash/GeoIP.dat
wget -qO- https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat > files/etc/openclash/GeoSite.dat
mkdir -p files/usr/share/xray
wget -qO- https://github.com/v2fly/geoip/releases/latest/download/geoip.dat > files/usr/share/xray/geoip.dat
wget -qO- https://github.com/v2fly/geoip/releases/latest/download/geosite.dat > files/usr/share/xray/geosite.dat

find ./ -name *.orig | xargs rm -f
find ./ -name *.rej | xargs rm -f

exit 0
