#!/bin/bash

. ../scripts/funcations.sh

./scripts/feeds update -a
./scripts/feeds install -a

### Prepare package
# Default settings
rm ./package/emortal/default-settings/files/openwrt_banner
sed -i '/openwrt_banner/d' ./package/emortal/default-settings/files/99-default-settings
sed -i '/etc$/,+2d' ./package/emortal/default-settings/Makefile
# Mosdns
cp -rf ../mosdns ./package/luci-app-mosdns
rm -rf ./feeds/packages/net/v2ray-geodata
cp -rf ../mosdns_pkg ./package/v2ray-geodata
# samba4
sed -i 's,\"nas\",\"services\",g' package/feeds/luci/luci-app-samba4/luasrc/controller/samba4.lua
# cpufreq
sed -i 's,\"system\",\"services\",g' package/feeds/luci/luci-app-cpufreq/luasrc/controller/cpufreq.lua
# hd-idle
sed -i 's,\"nas\",\"services\",g' package/feeds/luci/luci-app-hd-idle/luasrc/controller/hd_idle.lua
# vsftpd
sed -i -e 's,\"nas\",\"services\",g' -e 's,NAS,Services,g' package/feeds/luci/luci-app-vsftpd/luasrc/controller/vsftpd.lua
# filebrowser
sed -i -e 's,\"nas\",\"services\",g' -e 's,NAS,Services,g' package/feeds/luci/luci-app-filebrowser/luasrc/controller/filebrowser.lua
sed -i 's,nas,services,g' package/feeds/luci/luci-app-filebrowser/luasrc/view/filebrowser/filebrowser_status.htm
# rclone
sed -i -e 's,\"nas\",\"services\",g' -e 's,NAS,Services,g' package/feeds/luci/luci-app-rclone/luasrc/controller/rclone.lua
# dockerman
pushd package/feeds/luci/luci-app-dockerman
docker_2_services
popd
# nlbw
sed -i -e 's|admin\",|& \"network\",|g' -e 's,admin/,&network/,g' package/feeds/luci/luci-app-nlbwmon/luasrc/controller/nlbw.lua
sed -i 's,admin/,&network/,g' package/feeds/luci/luci-app-nlbwmon/luasrc/model/cbi/nlbw/config.lua
sed -i 's,admin/,&network/,g' package/feeds/luci/luci-app-nlbwmon/luasrc/view/nlbw/backup.htm
sed -i 's,admin/,&network/,g' package/feeds/luci/luci-app-nlbwmon/luasrc/view/nlbw/display.htm
# sirpdboy
mkdir -p package/sirpdboy
cp -rf ../sirpdboy/luci-app-autotimeset ./package/sirpdboy/luci-app-autotimeset
sed -i 's,"control","system",g' package/sirpdboy/luci-app-autotimeset/luasrc/controller/autotimeset.lua
sed -i '/firstchild/d' package/sirpdboy/luci-app-autotimeset/luasrc/controller/autotimeset.lua
sed -i 's,control,system,g' package/sirpdboy/luci-app-autotimeset/luasrc/view/autotimeset/log.htm
sed -i '/start()/a \    echo "Service autotimesetrun started!" >/dev/null' package/sirpdboy/luci-app-autotimeset/root/etc/init.d/autotimesetrun
rm -rf ./package/sirpdboy/luci-app-autotimeset/po/zh_Hans
# v2raya
git clone -b 18.06 --depth 1 https://github.com/zxlhhyccc/luci-app-v2raya.git package/new/luci-app-v2raya
# verysync
pushd package/feeds/luci/luci-app-verysync
move_2_services nas
popd
# NetSpeedTest
cp -rf ../netspeedtest package/netspeedtest

exit 0
