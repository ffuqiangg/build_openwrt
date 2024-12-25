#!/bin/bash

. ../scripts/functions.sh

### 基础部分 ###
# 使用 O2 级别的优化
sed -i 's/Os/O2/g' include/target.mk
# 更新 Feeds
./scripts/feeds update -a
./scripts/feeds install -a
# 默认开启 Irqbalance
sed -i "s/enabled '0'/enabled '1'/g" feeds/packages/utils/irqbalance/files/irqbalance.config

### 替换准备 ###
cp -rf ../openwrt-apps ./package/new
rm -rf feeds/packages/net/{xray-core,v2ray-core,v2ray-geodata,frp,shadowsocks-libev,v2raya,curl}
rm -rf feeds/luci/applications/{luci-app-frps,luci-app-frpc,luci-app-v2raya,luci-app-dockerman}
rm -rf feeds/packages/utils/coremark
rm -rf ./package/new/{autocore-arm,imm_pkg/filebrowser,luci-app-filebrowser-go}

### 获取额外的 LuCI 应用和依赖 ###
# 调整刷机脚本
patch -p1 < ../patch/custom_install/istoreos/custom_target_amlogic_scripts.patch
# 调整 default settings
sed -i '/overlay\/upper/d' package/istoreos-files/files/etc/uci-defaults/09_istoreos
sed -i 'N;/\n.*commit dockerd/!P;D' package/istoreos-files/files/etc/uci-defaults/09_istoreos 
sed -i '/commit dockerd/{N;d;}' package/istoreos-files/files/etc/uci-defaults/09_istoreos
# Golang
rm -rf ./feeds/packages/lang/golang
cp -rf ../openwrt_pkg_ma/lang/golang ./feeds/packages/lang/golang
# 预编译 node
rm -rf feeds/packages/lang/node
cp -rf ../node feeds/packages/lang/node
# Autocore
git clone --depth 1 -b openwrt-22.03 https://github.com/sbwml/autocore-arm.git ./package/new/autocore-arm
sed -i 's/?/ARMv8 Processor/' package/new/autocore-arm/files/generic/cpuinfo
# Docker 容器
cp -rf ../dockerman/applications/luci-app-dockerman feeds/luci/applications/luci-app-dockerman
sed -i '/auto_start/d' feeds/luci/applications/luci-app-dockerman/root/etc/uci-defaults/luci-app-dockerman
pushd package/feeds/luci/luci-app-dockerman
docker_2_services
popd
# Nlbw 带宽监控
sed -i 's,services,network,g' feeds/luci/applications/luci-app-nlbwmon/root/usr/share/luci/menu.d/luci-app-nlbwmon.json
# 终端 TTYD
sed -i 's,services,system,g' feeds/luci/applications/luci-app-ttyd/root/usr/share/luci/menu.d/luci-app-ttyd.json
# Curl
cp -rf ../openwrt_pkg_ma/net/curl ./feeds/packages/net/curl
cp -rf ../openwrt_pkg_ma/libs/nghttp3 ./feeds/packages/libs/nghttp3
ln -sf ../../../feeds/packages/libs/nghttp3 ./package/feeds/packages/nghttp3
cp -rf ../openwrt_pkg_ma/libs/ngtcp2 ./feeds/packages/libs/ngtcp2
ln -sf ../../../feeds/packages/libs/ngtcp2 ./package/feeds/packages/ngtcp2
# Filebrowser
cp -rf ../immortalwrt_luci_21/applications/luci-app-filebrowser ./package/new/luci-app-filebrowser
sed -i 's|\.\./\.\.|$(TOPDIR)/feeds/luci|g' package/new/luci-app-filebrowser/Makefile
cp -rf ../immortalwrt_pkg_21/utils/filebrowser ./package/new/filebrowser
sed -i 's|\.\./\.\.|$(TOPDIR)/feeds/packages|g' package/new/filebrowser/Makefile
sed -i "s,PKG_VERSION:=.*,PKG_VERSION:=2\.31\.2," package/new/filebrowser/Makefile
sed -i "s,PKG_HASH:=.*,PKG_HASH:=bfda9ea7c44d4cb93c47a007c98b84f853874e043049b44eff11ca00157d8426," package/new/filebrowser/Makefile

# 预配置一些插件
mkdir -p files
sed -i 's,/bin/ash,/bin/bash,' ./package/base-files/files/etc/passwd && sed -i 's,/bin/ash,/bin/bash,' ./package/base-files/files/usr/libexec/login.sh
cp -rf ../files/{init/*,cpufreq/*} files/
mkdir -p files/etc/uci-defaults
cp -f ../patch/default-settings/istoreos/zzz-default-settings ./files/etc/uci-defaults/
mkdir -p files/etc/openclash/core
wget -qO- https://github.com/vernesong/OpenClash/raw/core/master/meta/clash-linux-arm64.tar.gz | tar xOvz > files/etc/openclash/core/clash_meta
chmod +x files/etc/openclash/core/clash*

find ./ -name *.orig | xargs rm -f
find ./ -name *.rej | xargs rm -f

exit 0
