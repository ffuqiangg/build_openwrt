#!/bin/bash

source ../scripts/funcations.sh

### 基础部分 ###
# 使用 O2 级别的优化
sed -i 's/Os/O2/g' include/target.mk
# 默认开启 Irqbalance
sed -i "s/enabled '0'/enabled '1'/g" feeds/packages/utils/irqbalance/files/irqbalance.config

### 获取额外的 LuCI 应用和依赖 ###
mkdir -p ./package/new

# Filebrowser 文件浏览器
cp -rf ../lienol_pkg/luci-app-filebrowser ./package/new/luci-app-filebrowser
pushd package/new/luci-app-filebrowser
move_2_services nas
popd
# Dockerman
pushd package/feeds/luci/luci-app-dockerman
docker_2_services
popd
# DiskMan
cp -rf ../diskman/applications/luci-app-diskman ./package/new/luci-app-diskman
mkdir -p package/parted && \
wget https://raw.githubusercontent.com/lisaac/luci-app-diskman/master/Parted.Makefile -O package/parted/Makefile
# Mihomo
cp -rf ../mihomo ./package/new/mihomo
# Vsftpd
cp -rf ../lede_luci/applications/luci-app-vsftpd ./package/new/luci-app-vsftpd
cp -rf ../lede/package/lean/vsftpd-alt ./package/new/vsftpd-alt
pushd package/new/luci-app-vsftpd
move_2_services nas
popd
# Verysync
cp -rf ../immortalwrt_luci_23/applications/luci-app-verysync ./package/new/luci-app-verysync
cp -rf ../immortalwrt_pkg/net/verysync ./package/new/verysync
pushd package/new/luci-app-verysync
move_2_services nas
popd
# CPU 调度
cp -rf ../lede_luci/applications/luci-app-cpufreq ./package/new/luci-app-cpufreq
sed -i 's,\"system\",\"services\",g' ./package/new/luci-app-cpufreq/luasrc/controller/cpufreq.lua
# Passwall
cp -rf ../immortalwrt_luci_21/applications/luci-app-passwall ./package/new/luci-app-passwall
cp -rf ../immortalwrt_pkg_21/net/brook ./package/new/brook
cp -rf ../immortalwrt_pkg_21/net/hysteria ./package/new/hysteria
cp -rf ../immortalwrt_pkg_21/net/naiveproxy ./package/new/naiveproxy
cp -rf ../immortalwrt_pkg_21/net/shadowsocks-rust ./package/new/shadowsocks-rust
cp -rf ../immortalwrt_pkg_21/net/simple-obfs ./package/new/simple-obfs
cp -rf ../immortalwrt_pkg_21/net/chinadns-ng ./package/new/chinadns-ng
cp -rf ../immortalwrt_pkg_21/devel/gn ./feeds/packages/devel/gn
ln -sf ../../../feeds/packages/devel/gn ./package/feeds/packages/gn
# Mosdns
rm -rf ./feeds/packages/net/v2ray-geodata
cp -rf ../mosdns ./package/luci-app-mosdns

# 预配置一些插件
cp -rf ../patch/files ./files
sed -i 's,/bin/ash,/bin/bash,' ./package/base-files/files/etc/passwd && sed -i 's,/bin/ash,/bin/bash,' ./package/base-files/files/usr/libexec/login.sh
mkdir -p files/usr/share/xray
wget -qO- https://github.com/v2fly/geoip/releases/latest/download/geoip.dat > files/usr/share/xray/geoip.dat
wget -qO- https://github.com/v2fly/geoip/releases/latest/download/geosite.dat > files/usr/share/xray/geosite.dat

chmod -R 755 ./
find ./ -name *.orig | xargs rm -f
find ./ -name *.rej | xargs rm -f

exit 0
