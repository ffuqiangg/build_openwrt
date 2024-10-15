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
# KMS 激活助手
cp -rf ../lede_luci/applications/luci-app-vlmcsd ./package/new/luci-app-vlmcsd
cp -rf ../lede_pkg/net/vlmcsd ./package/new/vlmcsd
# Vsftpd
cp -rf ../lede_luci/applications/luci-app-vsftpd ./package/new/luci-app-vsftpd
cp -rf ../lede/package/lean/vsftpd-alt ./package/new/vsftpd-alt
pushd package/new/luci-app-vsftpd
move_2_services nas
popd
# Sing-box
cp -rf ../immortalwrt_pkg/net/sing-box ./package/new/sing-box
cp -f ../patch/sing-box/files/sing-box.init ./package/new/sing-box/files/sing-box.init
sed -i '63i\GO_PKG_TARGET_VARS:=$(filter-out CGO_ENABLED=%,$(GO_PKG_TARGET_VARS)) CGO_ENABLED=1\n' ./package/new/sing-box/Makefile
# 更换 golang 版本
rm -rf ./feeds/packages/lang/golang
cp -rf ../openwrt_pkg_ma/lang/golang ./feeds/packages/lang/golang
# FRP 内网穿透
rm -rf ./feeds/luci/applications/luci-app-frps
rm -rf ./feeds/luci/applications/luci-app-frpc
rm -rf ./feeds/packages/net/frp
rm -f ./package/feeds/packages/frp
cp -rf ../lede_luci/applications/luci-app-frps ./package/new/luci-app-frps
cp -rf ../lede_luci/applications/luci-app-frpc ./package/new/luci-app-frpc
cp -rf ../lede_pkg/net/frp ./package/new/frp

# 预配置一些插件
cp -rf ../patch/files ./files
sed -i 's,/bin/ash,/bin/bash,' ./package/base-files/files/etc/passwd && sed -i 's,/bin/ash,/bin/bash,' ./package/base-files/files/usr/libexec/login.sh

chmod -R 755 ./
find ./ -name *.orig | xargs rm -f
find ./ -name *.rej | xargs rm -f

exit 0
