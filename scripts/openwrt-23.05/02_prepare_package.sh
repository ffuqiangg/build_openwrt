#!/bin/bash

. ../scripts/funcations.sh

### 基础部分 ###
# 使用 O2 级别的优化
sed -i 's/Os/O2/g' include/target.mk
# 默认开启 Irqbalance
sed -i "s/enabled '0'/enabled '1'/g" feeds/packages/utils/irqbalance/files/irqbalance.config
# 移除 SNAPSHOT 标签
# sed -i 's,-SNAPSHOT,,g' include/version.mk
# sed -i 's,-SNAPSHOT,,g' package/base-files/image-config.in

### Fullcone-NAT 部分 ###
# Patch Kernel 以解决 FullCone 冲突
cp -rf ../lede/target/linux/generic/hack-5.15/952-add-net-conntrack-events-support-multiple-registrant.patch ./target/linux/generic/hack-5.15/952-add-net-conntrack-events-support-multiple-registrant.patch
# Patch FireWall 以增添 FullCone 功能
# FW4
mkdir -p package/network/config/firewall4/patches
cp -f ../patch/firewall/firewall4_patches/*.patch ./package/network/config/firewall4/patches/
mkdir -p package/libs/libnftnl/patches
cp -f ../patch/firewall/libnftnl/*.patch ./package/libs/libnftnl/patches/
sed -i '/PKG_INSTALL:=/iPKG_FIXUP:=autoreconf' package/libs/libnftnl/Makefile
mkdir -p package/network/utils/nftables/patches
cp -f ../patch/firewall/nftables/*.patch ./package/network/utils/nftables/patches/
# Patch LuCI 以支持自定义 nft 规则
patch -p1 < ../patch/firewall/100-openwrt-firewall4-add-custom-nft-command-support.patch
# FW3
mkdir -p package/network/config/firewall/patches
cp -rf ../immortalwrt_21/package/network/config/firewall/patches/100-fullconenat.patch ./package/network/config/firewall/patches/100-fullconenat.patch
cp -rf ../lede/package/network/config/firewall/patches/101-bcm-fullconenat.patch ./package/network/config/firewall/patches/101-bcm-fullconenat.patch
# iptables
cp -rf ../lede/package/network/utils/iptables/patches/900-bcm-fullconenat.patch ./package/network/utils/iptables/patches/900-bcm-fullconenat.patch
# network
wget -qO - https://github.com/openwrt/openwrt/commit/bbf39d07.patch | patch -p1
# Patch LuCI 以增添 FullCone 开关
pushd feeds/luci
patch -p1 <../../../patch/firewall/01-luci-app-firewall_add_nft-fullcone-bcm-fullcone_option.patch
popd
# FullCone PKG
git clone --depth 1 https://github.com/fullcone-nat-nftables/nft-fullcone package/new/nft-fullcone
cp -rf ../Lienol/package/network/utils/fullconenat ./package/new/fullconenat

### 获取额外的基础软件包 ###
# 更换为 ImmortalWrt Uboot 以及 Target
cp -rf ../lede/target/linux/amlogic ./target/linux/amlogic
rm -f ./target/linux/amlogic/patches-5.15/*
wget -P ./target/linux/amlogic/patches-5.15 https://raw.githubusercontent.com/coolsnowwolf/lede/6e604e9875c6dfdc44345254cc4c86bfe3694902/target/linux/amlogic/patches-5.15/001-dts-s905d-fix-high-load.patch
wget -P ./target/linux/amlogic/patches-5.15 https://raw.githubusercontent.com/coolsnowwolf/lede/6e604e9875c6dfdc44345254cc4c86bfe3694902/target/linux/amlogic/patches-5.15/002-dts-improve-phicomm-n1-support.patch
cp -rf ../lede/package/boot/uboot-amlogic ./package/boot/uboot-amlogic
cp -f ../lede/include/kernel-6.1 ./include/kernel-6.1
# rm -rf ./package/kernel
# cp -rf ../lede/package/kernel ./package/kernel
rm -rf ./target/linux/generic
cp -rf ../lede/target/linux/generic ./target/linux/generic
sed -i '/TARGET_rockchip/a\		default y if TARGET_amlogic' ./package/kernel/mac80211/broadcom.mk

### 获取额外的 LuCI 应用和依赖 ###
# 预编译 node
rm -rf feeds/packages/lang/node
cp -rf ../node feeds/packages/lang/node
# dae ready
cp -rf ../immortalwrt_pkg/net/dae ./feeds/packages/net/dae
ln -sf ../../../feeds/packages/net/dae ./package/feeds/packages/dae
cp -rf ../immortalwrt_pkg/net/daed ./feeds/packages/net/daed
ln -sf ../../../feeds/packages/net/daed ./package/feeds/packages/daed
cp -rf ../lucidaednext/daed-next ./package/new/daed-next
cp -rf ../lucidaednext/luci-app-daed-next ./package/new/luci-app-daed-next
git clone -b master --depth 1 https://github.com/QiuSimons/luci-app-daed package/new/luci-app-daed
# bpf
wget -qO - https://github.com/immortalwrt/immortalwrt/commit/73e5679.patch | patch -p1
wget https://github.com/immortalwrt/immortalwrt/raw/openwrt-23.05/target/linux/generic/backport-5.15/051-v5.18-bpf-Add-config-to-allow-loading-modules-with-BTF-mismatch.patch -O target/linux/generic/backport-5.15/051-v5.18-bpf-Add-config-to-allow-loading-modules-with-BTF-mismatch.patch
# mount cgroupv2
pushd feeds/packages
patch -p1 <../../../patch/cgroupfs-mount/0001-fix-cgroupfs-mount.patch
popd
mkdir -p feeds/packages/utils/cgroupfs-mount/patches
cp -rf ../patch/cgroupfs-mount/900-mount-cgroup-v2-hierarchy-to-sys-fs-cgroup-cgroup2.patch ./feeds/packages/utils/cgroupfs-mount/patches/
cp -rf ../patch/cgroupfs-mount/901-fix-cgroupfs-umount.patch ./feeds/packages/utils/cgroupfs-mount/patches/
cp -rf ../patch/cgroupfs-mount/902-mount-sys-fs-cgroup-systemd-for-docker-systemd-suppo.patch ./feeds/packages/utils/cgroupfs-mount/patches/
# 晶晨宝盒
# git clone --depth 1 https://github.com/ophub/luci-app-amlogic.git ./package/new/luci-app-amlogic
# AutoCore
cp -rf ../immortalwrt_23/package/emortal/autocore ./package/new/autocore
sed -i 's/"getTempInfo" /"getTempInfo", "getCPUBench", "getCPUUsage" /g' package/new/autocore/files/luci-mod-status-autocore.json
cp -rf ../OpenWrt-Add/autocore/files/x86/autocore ./package/new/autocore/files/autocore
sed -i '/i386 i686 x86_64/{n;n;n;d;}' package/new/autocore/Makefile
sed -i '/i386 i686 x86_64/d' package/new/autocore/Makefile
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
# Boost 通用即插即用
rm -rf ./feeds/packages/net/miniupnpd
cp -rf ../openwrt_pkg_ma/net/miniupnpd ./feeds/packages/net/miniupnpd
pushd feeds/packages
patch -p1 <../../../patch/miniupnpd/01-set-presentation_url.patch
patch -p1 <../../../patch/miniupnpd/02-force_forwarding.patch
patch -p1 <../../../patch/miniupnpd/03-Update-301-options-force_forwarding-support.patch.patch
popd
pushd feeds/luci
wget -qO- https://github.com/openwrt/luci/commit/0b5fb915.patch | patch -p1
popd
# ChinaDNS
git clone -b luci --depth 1 https://github.com/QiuSimons/openwrt-chinadns-ng.git package/new/luci-app-chinadns-ng
cp -rf ../passwall_pkg/chinadns-ng ./package/new/chinadns-ng
# Docker 容器
rm -rf ./feeds/luci/applications/luci-app-dockerman
cp -rf ../dockerman/applications/luci-app-dockerman ./feeds/luci/applications/luci-app-dockerman
pushd feeds/luci/applications/luci-app-dockerman
docker_2_services
popd
sed -i '/auto_start/d' ./feeds/luci/applications/luci-app-dockerman/root/etc/uci-defaults/luci-app-dockerman
pushd feeds/packages
wget -qO- https://github.com/openwrt/packages/commit/e2e5ee69.patch | patch -p1
wget -qO- https://github.com/openwrt/packages/pull/20054.patch | patch -p1
popd
sed -i '/sysctl.d/d' ./feeds/packages/utils/dockerd/Makefile
rm -rf ./feeds/luci/collections/luci-lib-docker
cp -rf ../docker_lib/collections/luci-lib-docker ./feeds/luci/collections/luci-lib-docker
# DiskMan
cp -rf ../diskman/applications/luci-app-diskman ./package/new/luci-app-diskman
mkdir -p package/parted && \
wget https://raw.githubusercontent.com/lisaac/luci-app-diskman/master/Parted.Makefile -O package/parted/Makefile
# FRP 内网穿透
rm -rf ./feeds/luci/applications/luci-app-frps
rm -rf ./feeds/luci/applications/luci-app-frpc
rm -rf ./feeds/packages/net/frp
cp -rf ../immortalwrt_pkg/net/frp ./feeds/packages/net/frp
sed -i '/etc/d' ./feeds/packages/net/frp/Makefile
sed -i '/defaults/{N;d;}' ./feeds/packages/net/frp/Makefile
cp -rf ../lede_luci/applications/luci-app-frps ./feeds/luci/applications/luci-app-frps
cp -rf ../lede_luci/applications/luci-app-frpc ./feeds/luci/applications/luci-app-frpc
# Sing-box
rm -rf ./feeds/packages/net/sing-box
cp -rf ../immortalwrt_pkg/net/sing-box ./feeds/packages/net/sing-box
cp -f ../patch/sing-box/files/sing-box.init ./feeds/packages/net/sing-box/files/sing-box.init
sed -i '63i\GO_PKG_TARGET_VARS:=$(filter-out CGO_ENABLED=%,$(GO_PKG_TARGET_VARS)) CGO_ENABLED=1\n' ./feeds/packages/net/sing-box/Makefile
# OpenClash
cp -rf ../openclash ./package/luci-app-openclash
# golang
rm -rf ./feeds/packages/lang/golang
cp -rf ../openwrt_pkg_ma/lang/golang ./feeds/packages/lang/golang
# Passwall
cp -rf ../passwall_luci/luci-app-passwall ./package/new/luci-app-passwall
pushd package/new/luci-app-passwall
move_2_services vpn
popd
cp -rf ../passwall_pkg/tcping ./package/new/tcping
cp -rf ../passwall_pkg/trojan-go ./package/new/trojan-go
cp -rf ../passwall_pkg/brook ./package/new/brook
cp -rf ../passwall_pkg/ssocks ./package/new/ssocks
cp -rf ../passwall_pkg/microsocks ./package/new/microsocks
cp -rf ../passwall_pkg/dns2socks ./package/new/dns2socks
cp -rf ../passwall_pkg/dns2tcp ./package/new/dns2tcp
cp -rf ../passwall_pkg/ipt2socks ./package/new/ipt2socks
cp -rf ../passwall_pkg/pdnsd-alt ./package/new/pdnsd-alt
cp -rf ../OpenWrt-Add/trojan-plus ./package/new/trojan-plus
cp -rf ../passwall_pkg/xray-plugin ./package/new/xray-plugin
cp -rf ../passwall_pkg/hysteria ./package/new/hysteria
rm -rf ./feeds/packages/net/xray-core
cp -rf ../sbwml/xray-core ./feeds/packages/net/xray-core
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
' >>./package/new/luci-app-passwall/root/usr/share/passwall/rules/direct_host
# Mosdns
rm -rf ./feeds/packages/net/v2ray-geodata
cp -rf ../mosdns ./package/new/luci-app-mosdns
git clone https://github.com/sbwml/v2ray-geodata package/new/v2ray-geodata
# 清理内存
cp -rf ../lede_luci/applications/luci-app-ramfree ./package/new/luci-app-ramfree
# v2raya
git clone --depth 1 https://github.com/v2rayA/v2raya-openwrt.git luci-app-v2raya
cp -rf ./luci-app-v2raya/luci-app-v2raya ./package/new/
rm -rf ./luci-app-v2raya
rm -rf ./feeds/packages/net/v2raya
cp -rf ../openwrt_pkg_ma/net/v2raya ./feeds/packages/net/v2raya
ln -sf ../../../feeds/packages/net/v2raya ./package/feeds/packages/v2raya
# KMS 激活助手
cp -rf ../lede_luci/applications/luci-app-vlmcsd ./package/new/luci-app-vlmcsd
cp -rf ../lede_pkg/net/vlmcsd ./package/new/vlmcsd
# Vsftpd
cp -rf ../lede_luci/applications/luci-app-vsftpd ./package/new/luci-app-vsftpd
cp -rf ../lede/package/lean/vsftpd-alt ./package/new/vsftpd-alt
pushd package/new/luci-app-vsftpd
move_2_services nas
popd
# Filebrowser 文件浏览器
cp -rf ../Lienol_pkg/luci-app-filebrowser ./package/new/luci-app-filebrowser
pushd package/new/luci-app-filebrowser
move_2_services nas
popd
# nlbw
sed -i 's,services,network,g' package/feeds/luci/luci-app-nlbwmon/root/usr/share/luci/menu.d/luci-app-nlbwmon.json
# ttyd
sed -i 's,services,system,g' package/feeds/luci/luci-app-ttyd/root/usr/share/luci/menu.d/luci-app-ttyd.json
# verysync
cp -rf ../immortalwrt_luci_23/applications/luci-app-verysync ./package/new/luci-app-verysync
cp -rf ../immortalwrt_pkg/net/verysync ./package/new/verysync
pushd package/new/luci-app-verysync
move_2_services nas
popd
# 翻译及部分功能优化
cp -rf ../OpenWrt-Add/addition-trans-zh ./package/new/addition-trans-zh
cp -f ../patch/addition-trans-zh/files/zzz-default-settings ./package/new/addition-trans-zh/files/zzz-default-settings
sed -i 's,iptables-mod-fullconenat,iptables-nft +kmod-nft-fullcone,g' package/new/addition-trans-zh/Makefile

### 最后的收尾工作 ###
# 生成默认配置及缓存
rm -rf .config
sed -i 's,CONFIG_WERROR=y,# CONFIG_WERROR is not set,g' target/linux/generic/config-5.15

#Vermagic
# latest_version="$(curl -s https://github.com/openwrt/openwrt/tags | grep -Eo "v[0-9\.]+\-*r*c*[0-9]*.tar.gz" | sed -n '/23.05/p' | sed -n 1p | sed 's/v//g' | sed 's/.tar.gz//g')"
# wget https://downloads.openwrt.org/releases/${latest_version}/targets/armsr/armv8/packages/Packages.gz
# zgrep -m 1 "Depends: kernel (=.*)$" Packages.gz | sed -e 's/.*-\(.*\))/\1/' >.vermagic
echo 'b8bb5886a3b5c15d5935e6bbba7303fe' > .vermagic
sed -i -e 's/^\(.\).*vermagic$/\1cp $(TOPDIR)\/.vermagic $(LINUX_DIR)\/.vermagic/' include/kernel-defaults.mk

# 预配置一些插件
cp -rf ../patch/files ./files
cp -rf ../patch/openwrt-23.05/. ./files/
mkdir -p files/etc/openclash/core
pushd files/etc/openclash/core
clash_version="$(curl -fsSL https://github.com/vernesong/OpenClash/raw/core/master/core_version | sed -n '2p')"
wget https://github.com/vernesong/OpenClash/raw/core/master/premium/clash-linux-arm64-${clash_version}.gz && gzip -d clash-linux-arm64-${clash_version}.gz && mv clash-linux-arm64-${clash_version} clash_tun
wget https://github.com/vernesong/OpenClash/raw/core/master/meta/clash-linux-arm64.tar.gz && tar -zxvf clash-linux-arm64.tar.gz && mv clash clash_meta
wget https://github.com/vernesong/OpenClash/raw/core/master/dev/clash-linux-arm64.tar.gz && tar -zxvf clash-linux-arm64.tar.gz.1
chmod +x ./clash*
find ./ -name "*.tar.gz*" | xargs rm -f
popd

chmod -R 755 ./
find ./ -name *.orig | xargs rm -f
find ./ -name *.rej | xargs rm -f

exit 0
