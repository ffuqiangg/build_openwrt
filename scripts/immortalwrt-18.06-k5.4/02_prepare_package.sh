#!/bin/bash

. ../scripts/funcations.sh

### Prepare package
# Default settings
rm ./package/emortal/default-settings/files/openwrt_banner
sed -i '/openwrt_banner/d' ./package/emortal/default-settings/files/99-default-settings
sed -i '/etc$/,+2d' ./package/emortal/default-settings/Makefile
# Mosdns
rm -rf ./feeds/packages/net/v2ray-geodata
cp -rf ../mosdns ./package/luci-app-mosdns
# Samba4
sed -i 's,\"nas\",\"services\",g' package/feeds/luci/luci-app-samba4/luasrc/controller/samba4.lua
# Cpufreq
sed -i 's,\"system\",\"services\",g' package/feeds/luci/luci-app-cpufreq/luasrc/controller/cpufreq.lua
# HD-idle
sed -i 's,\"nas\",\"services\",g' package/feeds/luci/luci-app-hd-idle/luasrc/controller/hd_idle.lua
# Vsftpd
sed -i -e 's,\"nas\",\"services\",g' -e 's,NAS,Services,g' package/feeds/luci/luci-app-vsftpd/luasrc/controller/vsftpd.lua
# Filebrowser
sed -i "s,PKG_VERSION:=.*,PKG_VERSION:=2\.31\.1," package/feeds/packages/filebrowser/Makefile
sed -i "s,PKG_MIRROR_HASH:=.*,PKG_MIRROR_HASH:=5917529F03F88AB3128C89C330BD9EABFADC05CF4179887FF3BA04A111888E49," package/feeds/packages/filebrowser/Makefile
sed -i -e 's,\"nas\",\"services\",g' -e 's,NAS,Services,g' package/feeds/luci/luci-app-filebrowser/luasrc/controller/filebrowser.lua
sed -i 's,nas,services,g' package/feeds/luci/luci-app-filebrowser/luasrc/view/filebrowser/filebrowser_status.htm
# Rclone
sed -i -e 's,\"nas\",\"services\",g' -e 's,NAS,Services,g' package/feeds/luci/luci-app-rclone/luasrc/controller/rclone.lua
# Dockerman
pushd package/feeds/luci/luci-app-dockerman
docker_2_services
popd
# Nlbw
sed -i -e 's|admin\",|& \"network\",|g' -e 's,admin/,&network/,g' package/feeds/luci/luci-app-nlbwmon/luasrc/controller/nlbw.lua
sed -i 's,admin/,&network/,g' package/feeds/luci/luci-app-nlbwmon/luasrc/model/cbi/nlbw/config.lua
sed -i 's,admin/,&network/,g' package/feeds/luci/luci-app-nlbwmon/luasrc/view/nlbw/backup.htm
sed -i 's,admin/,&network/,g' package/feeds/luci/luci-app-nlbwmon/luasrc/view/nlbw/display.htm
# V2raya
git clone -b 18.06 --depth 1 https://github.com/zxlhhyccc/luci-app-v2raya.git package/new/luci-app-v2raya
# Verysync
pushd package/feeds/luci/luci-app-verysync
move_2_services nas
popd
# mihomo
cp -rf ../mihomo ./package/mihomo

# 预配置一些插件
cp -rf ../patch/files ./files

chmod -R 755 ./
find ./ -name *.orig | xargs rm -f
find ./ -name *.rej | xargs rm -f

exit 0
