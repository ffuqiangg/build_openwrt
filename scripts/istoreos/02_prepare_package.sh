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
# Mosdns
cp -rf ../mosdns ./package/new/luci-app-mosdns
# # 更换 golang 版本
# rm -rf ./feeds/packages/lang/golang
# cp -rf ../openwrt_pkg_ma/lang/golang ./feeds/packages/lang/golang
# ln -sf ../../../feeds/packages/lang/golang/golang ./package/feeds/packages/golang
# # Passwall
# cp -rf ../passwall_luci/luci-app-passwall ./package/new/luci-app-passwall
# cp -rf ../passwall_pkg ./package/new/passwall-pkg
# rm -rf ./package/new/passwall-pkg/v2ray-geodata
# rm -rf ./feeds/packages/net/xray-core
# mv ./package/new/passwall-pkg/xray-core ./feeds/packages/net/xray-core
# cp -rf ../immortalwrt_pkg/net/sing-box ./package/new/passwall_pkg/sing-box
# cp -f ../patch/sing-box/files/sing-box.init ./package/new/passwall_pkg/sing-box/files/sing-box.init
# sed -i '63i\GO_PKG_TARGET_VARS:=$(filter-out CGO_ENABLED=%,$(GO_PKG_TARGET_VARS)) CGO_ENABLED=1\n' ./package/new/passwall_pkg/sing-box/Makefile
# # mkdir -p package/new/passwall-pkg/sing-box/files && \
# # cp -f ../patch/sing-box/files/sing-box.init ./package/new/passwall-pkg/sing-box/files/sing-box.init && \
# # patch -p1 < ../patch/sing-box/001-sing-box-add-init.patch
# # Passwall 白名单
# echo '
# teamviewer.com
# epicgames.com
# dangdang.com
# account.synology.com
# ddns.synology.com
# checkip.synology.com
# checkip.dyndns.org
# checkipv6.synology.com
# ntp.aliyun.com
# cn.ntp.org.cn
# ntp.ntsc.ac.cn
# ' >>./package/new/luci-app-passwall/root/usr/share/passwall/rules/direct_host
# # 添加 rust
# cp -rf ../lede_pkg/lang/rust ./feeds/packages/lang/rust
# ln -sf ../../../feeds/packages/lang/rust ./package/feeds/packages/rust
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

# 预配置一些插件
cp -rf ../patch/files ./files
sed -i 's,/bin/ash,/bin/bash,' ./package/base-files/files/etc/passwd && sed -i 's,/bin/ash,/bin/bash,' ./package/base-files/files/usr/libexec/login.sh

chmod -R 755 ./
find ./ -name *.orig | xargs rm -f
find ./ -name *.rej | xargs rm -f

exit 0
