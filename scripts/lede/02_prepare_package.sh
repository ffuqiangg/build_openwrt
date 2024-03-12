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
sed -i '/gVisor/{n;s/n/y/;}' ./package/passwall-pkg/sing-box/Makefile
# Openclash
cp -rf ../openclash ./package/luci-app-openclash
# Filebrowser
cp -rf ../lienol_pkg/luci-app-filebrowser ./package/luci-app-filebrowser
pushd package/luci-app-filebrowser
move_2_services nas
popd
# golang
rm -rf feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 22.x feeds/packages/lang/golang
# Mosdns
cp -rf ../mosdns ./package/luci-app-mosdns
rm -rf ./feeds/packages/net/v2ray-geodata
cp -rf ../mosdns_pkg ./package/v2ray-geodata
sed -i '39i\GO_PKG_TARGET_VARS:=$(filter-out CGO_ENABLED=%,$(GO_PKG_TARGET_VARS)) CGO_ENABLED=1\n' ./package/luci-app-mosdns/mosdns/Makefile
sed -i '40i\nGO_PKG_TARGET_VARS:=$(filter-out CGO_ENABLED=%,$(GO_PKG_TARGET_VARS)) CGO_ENABLED=1' ./package/luci-app-mosdns/v2dat/Makefile
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
# v2raya
git clone -b 18.06 --depth 1 https://github.com/zxlhhyccc/luci-app-v2raya.git package/new/luci-app-v2raya
cp -rf ../immortalwrt_pkg_18.06/net/v2raya ./feeds/packages/net/v2raya
ln -sf ../../../feeds/packages/net/v2raya ./package/feeds/packages/v2raya
# verysync
pushd package/feeds/luci/luci-app-verysync
move_2_services nas
popd
# curl 8.6.0 passwall 冲突降级
sed -i "s,PKG_VERSION:=.*,PKG_VERSION:=8\.5\.0," ./feeds/packages/net/curl/Makefile
sed -i "s,PKG_HASH:=.*,PKG_HASH:=ce4b6a6655431147624aaf582632a36fe1ade262d5fab385c60f78942dd8d87b," ./feeds/packages/net/curl/Makefile

# fix xfsprogs
sed -i 's,TARGET_CFLAGS += -DHAVE_MAP_SYNC,& -D_LARGEFILE64_SOURCE,' feeds/packages/utils/xfsprogs/Makefile

exit 0
