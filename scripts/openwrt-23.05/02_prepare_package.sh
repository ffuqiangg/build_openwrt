#!/bin/bash

./scripts/feeds update -a
./scripts/feeds install -a

# 移除 SNAPSHOT 标签
sed -i 's,-SNAPSHOT,,g' include/version.mk
sed -i 's,-SNAPSHOT,,g' package/base-files/image-config.in

### 获取额外的 LuCI 应用、主题和依赖 ###
# AutoCore
cp -rf ../immortalwrt_23/package/emortal/autocore ./package/autocore
sed -i 's/"getTempInfo" /"getTempInfo", "getCPUBench", "getCPUUsage" /g' package/autocore/files/luci-mod-status-autocore.json
cp -rf ../OpenWrt-Add/autocore/files/x86/autocore ./package/autocore/files/autocore
sed -i '/i386 i686 x86_64/{n;n;n;d;}' package/autocore/Makefile
sed -i '/i386 i686 x86_64/d' package/autocore/Makefile
rm -rf ./feeds/luci/modules/luci-base
cp -rf ../immortalwrt_luci_23/modules/luci-base ./feeds/luci/modules/luci-base
sed -i "s,(br-lan),,g" feeds/luci/modules/luci-base/root/usr/share/rpcd/ucode/luci
rm -rf ./feeds/luci/modules/luci-mod-status
cp -rf ../immortalwrt_luci_23/modules/luci-mod-status ./feeds/luci/modules/luci-mod-status
rm -rf ./feeds/packages/utils/coremark
cp -rf ../immortalwrt_pkg/utils/coremark ./feeds/packages/utils/coremark
sed -i "s,-O3,-Ofast -funroll-loops -fpeel-loops -fgcse-sm -fgcse-las,g" feeds/packages/utils/coremark/Makefile
cp -rf ../immortalwrt_23/package/utils/mhz ./package/utils/mhz
# MAC 地址与 IP 绑定
cp -rf ../immortalwrt_luci/applications/luci-app-arpbind ./feeds/luci/applications/luci-app-arpbind
ln -sf ../../../feeds/luci/applications/luci-app-arpbind ./package/feeds/luci/luci-app-arpbind
# 定时重启
cp -rf ../immortalwrt_luci/applications/luci-app-autoreboot ./feeds/luci/applications/luci-app-autoreboot
ln -sf ../../../feeds/luci/applications/luci-app-autoreboot ./package/feeds/luci/luci-app-autoreboot
# ChinaDNS
git clone -b luci --depth 1 https://github.com/QiuSimons/openwrt-chinadns-ng.git package/luci-app-chinadns-ng
cp -rf ../passwall_pkg/chinadns-ng ./package/chinadns-ng
# Docker 容器
rm -rf ./feeds/luci/applications/luci-app-dockerman
cp -rf ../dockerman/applications/luci-app-dockerman ./feeds/luci/applications/luci-app-dockerman
sed -i '/auto_start/d' feeds/luci/applications/luci-app-dockerman/root/etc/uci-defaults/luci-app-dockerman
pushd feeds/packages
wget -qO- https://github.com/openwrt/packages/commit/e2e5ee69.patch | patch -p1
wget -qO- https://github.com/openwrt/packages/pull/20054.patch | patch -p1
popd
sed -i '/sysctl.d/d' feeds/packages/utils/dockerd/Makefile
rm -rf ./feeds/luci/collections/luci-lib-docker
cp -rf ../docker_lib/collections/luci-lib-docker ./feeds/luci/collections/luci-lib-docker
# DiskMan
cp -rf ../diskman/applications/luci-app-diskman ./package/luci-app-diskman
mkdir -p package/parted && \
wget https://raw.githubusercontent.com/lisaac/luci-app-diskman/master/Parted.Makefile -O package/parted/Makefile
# FRP 内网穿透
rm -rf ./feeds/luci/applications/luci-app-frps
rm -rf ./feeds/luci/applications/luci-app-frpc
rm -rf ./feeds/packages/net/frp
cp -rf ../immortalwrt_pkg/net/frp ./feeds/packages/net/frp
sed -i '/etc/d' feeds/packages/net/frp/Makefile
sed -i '/defaults/{N;d;}' feeds/packages/net/frp/Makefile
cp -rf ../lede_luci/applications/luci-app-frps ./package/luci-app-frps
cp -rf ../lede_luci/applications/luci-app-frpc ./package/luci-app-frpc
sed -i '/luci.mk/c\include $(TOPDIR)/feeds/luci/luci.mk' ./package/luci-app-frps/Makefile
sed -i '/luci.mk/c\include $(TOPDIR)/feeds/luci/luci.mk' ./package/luci-app-frpc/Makefile
# Luci app amlogic
git clone --depth 1 https://github.com/ophub/luci-app-amlogic.git ./package/luci-app-amlogic
sed -i -e '/ROOT1=/c\ROOT1=\"720\"' -e '/ROOT2=/c\ROOT2=\"720\"' ./package/luci-app-amlogic/luci-app-amlogic/root/usr/sbin/openwrt-install-amlogic
# Mosdns
cp -rf ../mosdns/mosdns ./package/mosdns
cp -rf ../mosdns/luci-app-mosdns ./package/luci-app-mosdns
rm -rf ./feeds/packages/net/v2ray-geodata
cp -rf ../mosdns/v2ray-geodata ./package/v2ray-geodata
# homeproxy
git clone --single-branch --depth 1 -b dev https://github.com/immortalwrt/homeproxy.git ./package/luci-app-homeproxy
rm -rf ./feeds/packages/net/sing-box
cp -rf ../immortalwrt_pkg/net/sing-box ./feeds/packages/net/sing-box
# OpenClash
git clone --single-branch --depth 1 -b master https://github.com/vernesong/OpenClash.git ./package/luci-app-openclash
# Passwall
cp -rf ../passwall_luci/luci-app-passwall ./package/luci-app-passwall
wget -P package/luci-app-passwall/ https://github.com/QiuSimons/OpenWrt-Add/raw/master/move_2_services.sh
chmod -R 755 ./package/luci-app-passwall/move_2_services.sh
pushd package/luci-app-passwall
bash move_2_services.sh
popd
cp -rf ../passwall_pkg ./package/passwall_pkg
# Passwall 白名单
echo '
teamviewer.com
epicgames.com
dangdang.com
account.synology.com
ddns.synology.com
checkip.synology.com
checkip.dyndns.org
checkipv6.synology.com
ntp.aliyun.com
cn.ntp.org.cn
ntp.ntsc.ac.cn
' >>./package/luci-app-passwall/root/usr/share/passwall/rules/direct_host
# 清理内存
cp -rf ../lede_luci/applications/luci-app-ramfree ./package/luci-app-ramfree
sed -i '/luci.mk/c\include $(TOPDIR)/feeds/luci/luci.mk' ./package/luci-app-ramfree/Makefile
# KMS 激活助手
cp -rf ../lede_luci/applications/luci-app-vlmcsd ./package/luci-app-vlmcsd
sed -i '/luci.mk/c\include $(TOPDIR)/feeds/luci/luci.mk' ./package/luci-app-vlmcsd/Makefile
cp -rf ../lede_pkg/net/vlmcsd ./package/vlmcsd
# Vsftpd
# cp -rf ../lede_luci/applications/luci-app-vsftpd ./package/luci-app-vsftpd
# sed -i '/luci.mk/c\include $(TOPDIR)/feeds/luci/luci.mk' ./package/luci-app-vsftpd/Makefile
# cp -rf ../lede_pkg/net/vsftpd ./package/net/vsftpd
# Filebrowser 文件浏览器
cp -rf ../Lienol_pkg/luci-app-filebrowser ./package/luci-app-filebrowser
# Filetransfer
# cp -rf ../lede_luci/applications/luci-app-filetransfer ./package/luci-app-filetransfer
# sed -i '/luci.mk/c\include $(TOPDIR)/feeds/luci/luci.mk' ./package/luci-app-filetransfer/Makefile
# cp -rf ../lede_luci/libs/luci-app-fs ./package/libs/luci-app-fs
# Filebrowser
cp -rf ../Lienol_pkg/luci-app-filebrowser ./package/luci-app-filebrowser
pushd package/luci-app-filebrowser
bash ../scripts/move_2_services.sh nas
popd

exit 0
