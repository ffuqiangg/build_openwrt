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

### 替换源码 ###
rm -rf ./feeds/packages/net/{xray-core,v2ray-core,v2ray-geodata,shadowsocks-libev,v2raya,frp,vsftpd}
rm -rf ./feeds/luci/applications/{luci-app-v2raya,luci-app-dockerman,luci-app-frps,luci-app-frpc}
rm -rf ./feeds/packages/utils/coremark
mkdir -p ./package/new
cp -rf ../openwrt-apps/{openwrt_helloworld,luci-app-v2raya,luci-app-arpbind,addition-trans-zh,luci-app-cpulimit,OpenClash,luci-app-frps,luci-app-frpc,luci-app-mosdns} ./package/new/
cp -rf ../openwrt-apps/openwrt_pkgs/{luci-app-diskman,luci-app-autoreboot,coremark,luci-app-filebrowser-go,filebrowser} ./package/new/
cp -rf ../openwrt-apps/imm_pkg/{v2raya,frp,cpulimit} ./package/new/

### 获取额外的 LuCI 应用和依赖 ###
# 调整刷机脚本
patch -p1 < ../patch/custom_install/istoreos/custom_target_amlogic_scripts.patch
# 调整 default settings
sed -i '/dockerd.globals.data_root/d' package/istoreos-files/files/etc/uci-defaults/09_istoreos
sed -i 'N;/\n.*commit dockerd/!P;D' package/istoreos-files/files/etc/uci-defaults/09_istoreos 
sed -i '/commit dockerd/{N;d;}' package/istoreos-files/files/etc/uci-defaults/09_istoreos
# Golang
rm -rf ./feeds/packages/lang/golang
cp -rf ../openwrt_pkg_ma/lang/golang ./feeds/packages/lang/golang
# 预编译 node
rm -rf feeds/packages/lang/node
cp -rf ../node ./feeds/packages/lang/node
# Autocore
clone_repo https://github.com/sbwml/autocore-arm.git openwrt-22.03 package/new/autocore-arm
sed -i 's/?/ARMv8 Processor/' package/new/autocore-arm/files/generic/cpuinfo
# Docker 容器
cp -rf ../dockerman/applications/luci-app-dockerman ./feeds/luci/applications/luci-app-dockerman
sed -i '/auto_start/d' feeds/luci/applications/luci-app-dockerman/root/etc/uci-defaults/luci-app-dockerman
pushd package/feeds/luci/luci-app-dockerman
docker_2_services
popd
# Nlbw 带宽监控
sed -i 's,services,network,g' feeds/luci/applications/luci-app-nlbwmon/root/usr/share/luci/menu.d/luci-app-nlbwmon.json
sed -i 's,services,network,g' feeds/luci/applications/luci-app-nlbwmon/htdocs/luci-static/resources/view/nlbw/config.js
# 终端 TTYD
sed -i 's,services,system,g' feeds/luci/applications/luci-app-ttyd/root/usr/share/luci/menu.d/luci-app-ttyd.json
# Curl
patch -p1 < ../patch/curl/downgrade_curl_8.6.0_to_8.5.0.patch
# Cpufreq
cp -rf ../immortalwrt_luci_21/applications/luci-app-cpufreq package/new/luci-app-cpufreq
sed -i 's|\.\./\.\.|$(TOPDIR)/feeds/luci|g' package/new/luci-app-cpufreq/Makefile
# FTP 服务器
cp -rf ../immortalwrt_luci_21/applications/luci-app-vsftpd ./package/new/luci-app-vsftpd
sed -i 's|\.\./\.\.|$(TOPDIR)/feeds/luci|g' package/new/luci-app-vsftpd/Makefile
cp -rf ../immortalwrt_pkg_21/net/vsftpd ./package/new/vsftpd
pushd package/new/luci-app-vsftpd
move_2_services nas
popd

# 预配置一些插件
sed -i 's,/bin/ash,/bin/bash,' package/base-files/files/etc/passwd
sed -i 's,/bin/ash,/bin/bash,' package/base-files/files/usr/libexec/login.sh
mkdir -p ./files/etc/uci-defaults ./files/etc/openclash/core
cp -rf ../files/{init/*,cpufreq/*} files/
cp -f ../patch/default-settings/istoreos/zzz-default-settings ./files/etc/uci-defaults/
wget -qO- https://github.com/vernesong/OpenClash/raw/core/master/meta/clash-linux-arm64.tar.gz | tar xOvz > files/etc/openclash/core/clash_meta
chmod +x files/etc/openclash/core/clash*

# 清理临时文件
find ./ -name *.orig | xargs rm -f
find ./ -name *.rej | xargs rm -f

exit 0
