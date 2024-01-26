#!/bin/bash

. ../scripts/funcations.sh

./scripts/feeds update -a
./scripts/feeds install -a

### Prepare package
# Luci-app-amlogic
git clone --depth 1 https://github.com/ophub/luci-app-amlogic.git ./package/luci-app-amlogic
# Wget
rm -rf ./feeds/packages/net/wget
cp -rf ../lede_pkg/net/wget ./feeds/packages/net/wget
# Mosdns
cp -rf ../mosdns ./package/luci-app-mosdns
rm -rf ./feeds/packages/net/v2ray-geodata
cp -rf ../mosdns_pkg ./package/v2ray-geodata
# samba4
sed -i 's,nas,services,g' package/feeds/luci/luci-app-samba4/root/usr/share/luci/menu.d/luci-app-samba4.json
# cpufreq
sed -i 's,system,services,g' package/feeds/luci/luci-app-cpufreq/root/usr/share/luci/menu.d/luci-app-cpufreq.json
# hd-idle
sed -i 's,nas,services,g' package/feeds/luci/luci-app-hd-idle/root/usr/share/luci/menu.d/luci-app-hd-idle.json
# vsftpd
pushd package/feeds/luci/luci-app-vsftpd
move_2_services nas
popd
# filebrowser
sed -i "s,PKG_VERSION:=.*,PKG_VERSION:=2\.27\.0," package/feeds/packages/filebrowser/Makefile
sed -i "s,PKG_HASH:=.*,PKG_HASH:=3A60CF26D6DED863D730BC671EE8DF6DC342CAB6DD867C16370EECB186FFF655," package/feeds/packages/filebrowser/Makefile
# rclone
sed -i -e 's,\"nas\",\"services\",g' -e 's,NAS,Services,g' package/feeds/luci/luci-app-rclone/luasrc/controller/rclone.lua
# dockerman
pushd package/feeds/luci/luci-app-dockerman
docker_2_services
popd
sed -i -e 's/admin\",/& \"services\",/g' -e 's/Docker/&Man/' -e 's/config\")/overview\")/' ./package/feeds/luci/luci-app-dockerman/luasrc/controller/dockerman.lua
# nlbw
sed -i 's,services,network,g' package/feeds/luci/luci-app-nlbwmon/root/usr/share/luci/menu.d/luci-app-nlbwmon.json
# sirpdboy
mkdir -p package/sirpdboy
cp -rf ../sirpdboy/luci-app-autotimeset ./package/sirpdboy/luci-app-autotimeset
sed -i 's,"control","system",g' package/sirpdboy/luci-app-autotimeset/luasrc/controller/autotimeset.lua
sed -i '/firstchild/d' package/sirpdboy/luci-app-autotimeset/luasrc/controller/autotimeset.lua
sed -i 's,control,system,g' package/sirpdboy/luci-app-autotimeset/luasrc/view/autotimeset/log.htm
sed -i '/start()/a \    echo "Service autotimesetrun started!" >/dev/null' package/sirpdboy/luci-app-autotimeset/root/etc/init.d/autotimesetrun
rm -rf ./package/sirpdboy/luci-app-autotimeset/po/zh_Hans
# verysync
pushd package/feeds/luci/luci-app-verysync
move_2_services nas
popd

exit 0
