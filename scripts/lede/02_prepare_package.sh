#!/bin/bash

source ../scripts/funcations.sh

### 基础部分 ###
# 使用 O2 级别的优化
sed -i 's/Os/O2/g' include/target.mk
# 更新 Feeds
./scripts/feeds update -a
./scripts/feeds install -a
# 默认开启 Irqbalance
sed -i "s/enabled '0'/enabled '1'/g" feeds/packages/utils/irqbalance/files/irqbalance.config

### 替换准备 ###
rm -rf feeds/packages/net/{xray-core,v2ray-geodata,shadowsocks-libev,v2raya.mosdns}
rm -rf feeds/luci/applications/luci-app-v2raya

### 额外的 LuCI 应用和依赖 ###
mkdir -p package/new
# 调整 default settings
sed -i '/services/d' package/lean/default-settings/files/zzz-default-settings
# Passwall
cp -rf ../passwall_luci/luci-app-passwall ./package/new/luci-app-passwall
cp -rf ../passwall_pkg ./package/new/passwall-pkg
rm -rf ./package/new/passwall-pkg/v2ray-geodata
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
' >> ./package/new/luci-app-passwall/root/usr/share/passwall/rules/direct_host
# Opencalsh
cp -rf ../openclash ./package/new/luci-app-openclash
# Filebrowser
cp -rf ../lienol_pkg/luci-app-filebrowser ./package/new/luci-app-filebrowser
pushd package/luci-app-filebrowser
move_2_services nas
popd
# Mosdns
cp -rf ../mosdns ./package/new/luci-app-mosdns
cp -rf ../v2ray_geodata ./feeds/packages/net/v2ray-geodata
# Vsftpd
pushd feeds/luci/applications/luci-app-vsftpd
move_2_services nas
popd
# Cpufreq
sed -i 's,\"system\",\"services\",g' feeds/luci/applications/luci-app-cpufreq/luasrc/controller/cpufreq.lua
# Rclone
sed -i -e 's,\"NAS\",\"Services\",g' -e 's,\"nas\",\"services\",g' feeds/luci/applications/luci-app-rclone/luasrc/controller/rclone.lua
# Dockerman
pushd feeds/luci/applications/luci-app-dockerman
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
pushd package/feeds/luci/luci-app-verysync
move_2_services nas
popd
# Curl
sed -i "s,PKG_VERSION:=.*,PKG_VERSION:=8\.10\.1," ./feeds/packages/net/curl/Makefile
sed -i "s,PKG_HASH:=.*,PKG_HASH:=73a4b0e99596a09fa5924a4fb7e4b995a85fda0d18a2c02ab9cf134bebce04ee," ./feeds/packages/net/curl/Makefile

# fix xfsprogs
sed -i 's,TARGET_CFLAGS += -DHAVE_MAP_SYNC,& -D_LARGEFILE64_SOURCE,' feeds/packages/utils/xfsprogs/Makefile

# 预配置一些插件
cp -rf ../patch/files ./files
sed -i 's,/bin/ash,/bin/bash,' ./package/base-files/files/etc/passwd && sed -i 's,/bin/ash,/bin/bash,' ./package/base-files/files/usr/libexec/login.sh
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

chmod -R 755 ./
find ./ -name *.orig | xargs rm -f
find ./ -name *.rej | xargs rm -f

exit 0
