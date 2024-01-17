#!/bin/bash

. ../scripts/funcations.sh

./scripts/feeds update -a
./scripts/feeds install -a

### Prepare package
# Delete default menu setting
sed -i '/services/d' package/lean/default-settings/files/zzz-default-settings
# Passwall
cp -rf ../passwall_luci ./package/luci-app-passwall
cp -rf ../passwall_pkg ./package/passwall-pkg
# Openclash
cp -rf ../openclash ./package/luci-app-openclash
# Filebrowser
cp -rf ../lienol_pkg/luci-app-filebrowser ./package/luci-app-filebrowser
pushd package/luci-app-filebrowser
move_2_services nas
popd
# Mosdns
cp -rf ../mosdns/mosdns ./package/mosdns
cp -rf ../mosdns/luci-app-mosdns ./package/luci-app-mosdns
rm -rf ./feeds/packages/net/v2ray-geodata
cp -rf ../mosdns/v2ray-geodata ./package/v2ray-geodata
# vsftpd
pushd package/feeds/luci/luci-app-vsftpd
move_2_services nas
popd
# cpufreq
sed -i 's,\"system\",\"services\",g' package/feeds/luci/luci-app-cpufreq/luasrc/controller/cpufreq.lua
# rclone
sed -i -e 's,\"NAS\",\"Services\",g' -e 's,\"nas\",\"services\",g' package/feeds/luci/luci-app-rclone/luasrc/controller/rclone.lua
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
cp -rf ../immortalwrt_pkg_18.06/net/v2raya ./feeds/packages/net/v2raya
ln -sf ../../../feeds/packages/net/v2raya ./package/feeds/packages/v2raya
# verysync
cp -rf ../Lienol_pkg/luci-app-verysync ./package/luci-app-verysync
pushd package/luci-app-verysync
move_2_services nas
popd

exit 0
