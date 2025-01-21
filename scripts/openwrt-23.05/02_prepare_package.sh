#!/bin/bash

. ../scripts/functions.sh

### 基础部分 ###
# 使用 O2 级别的优化
sed -i 's/Os/O2/g' include/target.mk
# 更新 Feeds
./scripts/feeds update -a
./scripts/feeds install -a
# 移除 SNAPSHOT 标签
sed -i 's,-SNAPSHOT,,g' include/version.mk
sed -i 's,-SNAPSHOT,,g' package/base-files/image-config.in

### FIREWALL ###
# custom nft command
patch -p1 < ../patch/firewall/100-openwrt-firewall4-add-custom-nft-command-support.patch
# patch LuCI 以支持自定义 nft 规则
pushd feeds/luci
patch -p1 < ../../../patch/firewall/04-luci-add-firewall4-nft-rules-file.patch
popd

### Kernel Hack 部分 ###
# make olddefconfig
wget -qO - https://github.com/openwrt/openwrt/commit/c21a3570.patch | patch -p1
# btf
wget -qO - https://github.com/immortalwrt/immortalwrt/commit/73e5679.patch | patch -p1
wget https://github.com/immortalwrt/immortalwrt/raw/openwrt-23.05/target/linux/generic/backport-5.15/051-v5.18-bpf-Add-config-to-allow-loading-modules-with-BTF-mismatch.patch -O target/linux/generic/backport-5.15/051-v5.18-bpf-Add-config-to-allow-loading-modules-with-BTF-mismatch.patch
# bpf_loop
cp -f ../patch/bpf_loop/*.patch ./target/linux/generic/backport-5.15/

### 替换准备 ###
cp -rf ../openwrt-apps ./package/new
rm -rf package/new/{luci-app-frpc,luci-app-frps,imm_pkg/frp,openwrt_pkg/vlmcsd,openwrt_pkg/luci-app-vlmcsd,imm_pkg/filebrowser,luci-app-filebrowser-go}
rm -rf feeds/packages/net/{xray-core,v2ray-core,v2ray-geodata,sing-box,microsocks,shadowsocks-libev,zerotier,daed,v2raya}
rm -rf feeds/luci/applications/{luci-app-zerotier,luci-app-v2raya,luci-app-dockerman}
rm -rf feeds/packages/utils/coremark

### 获取额外的 LuCI 应用和依赖 ###
# 预编译 node
rm -rf ./feeds/packages/lang/node
cp -rf ../node ./feeds/packages/lang/node
# 更换 golang 版本
rm -rf ./feeds/packages/lang/golang
cp -rf ../openwrt_pkg_ma/lang/golang ./feeds/packages/lang/golang
# 添加翻译
cp -rf ../openwrt-apps/addition-trans-zh ./package/new/addition-trans-zh
# mount cgroupv2
pushd feeds/packages
patch -p1 < ../../../patch/cgroupfs-mount/0001-fix-cgroupfs-mount.patch
popd
mkdir -p feeds/packages/utils/cgroupfs-mount/patches
cp -rf ../patch/cgroupfs-mount/900-mount-cgroup-v2-hierarchy-to-sys-fs-cgroup-cgroup2.patch ./feeds/packages/utils/cgroupfs-mount/patches/
cp -rf ../patch/cgroupfs-mount/901-fix-cgroupfs-umount.patch ./feeds/packages/utils/cgroupfs-mount/patches/
cp -rf ../patch/cgroupfs-mount/902-mount-sys-fs-cgroup-systemd-for-docker-systemd-suppo.patch ./feeds/packages/utils/cgroupfs-mount/patches/
# Docker 容器
cp -rf ../dockerman/applications/luci-app-dockerman ./feeds/luci/applications/luci-app-dockerman
sed -i '/auto_start/d' feeds/luci/applications/luci-app-dockerman/root/etc/uci-defaults/luci-app-dockerman
pushd feeds/luci/applications/luci-app-dockerman
docker_2_services
popd
# nlbw
sed -i 's,services,network,g' package/feeds/luci/luci-app-nlbwmon/root/usr/share/luci/menu.d/luci-app-nlbwmon.json
# ttyd
sed -i 's,services,system,g' package/feeds/luci/luci-app-ttyd/root/usr/share/luci/menu.d/luci-app-ttyd.json
# KMS 服务器
cp -rf ../immortalwrt_luci_23/applications/luci-app-vlmcsd ./package/new/luci-app-vlmcsd
sed -i 's|\.\./\.\.|$(TOPDIR)/feeds/luci|g' package/new/luci-app-vlmcsd/Makefile
cp -rf ../immortalwrt_pkg_23/net/vlmcsd ./package/new/vlmcsd
# 晶晨宝盒
cp -rf ../amlogic/luci-app-amlogic ./package/new/luci-app-amlogic
# Filebrowser
cp -rf ../immortalwrt_luci_23/applications/luci-app-filebrowser ./package/new/luci-app-filebrowser
sed -i 's|\.\./\.\.|$(TOPDIR)/feeds/luci|g' package/new/luci-app-filebrowser/Makefile
cp -rf ../immortalwrt_pkg_23/utils/filebrowser ./package/new/filebrowser
sed -i 's|\.\./\.\.|$(TOPDIR)/feeds/packages|g' package/new/filebrowser/Makefile
sed -i "s,PKG_VERSION:=.*,PKG_VERSION:=2\.31\.2," package/new/filebrowser/Makefile
sed -i "s,PKG_HASH:=.*,PKG_HASH:=bfda9ea7c44d4cb93c47a007c98b84f853874e043049b44eff11ca00157d8426," package/new/filebrowser/Makefile
# Sing-box
cp -rf ../patch/sing-box_nftables ./package/new/openwrt_helloworld/sing-box/files
sed -i '/sing-box.conf/a\	$(INSTALL_CONF) ./files/template.json $(1)/etc/config/sing-box' package/new/openwrt_helloworld/sing-box/Makefile
sed -i '/sing-box.conf/a\	$(INSTALL_CONF) ./files/nftables.rules $(1)/etc/config/sing-box' package/new/openwrt_helloworld/sing-box/Makefile

# 生成默认配置及缓存
rm -rf .config
sed -i 's,CONFIG_WERROR=y,# CONFIG_WERROR is not set,g' target/linux/generic/config-5.15

#Vermagic
latest_version="$(curl -s https://github.com/openwrt/openwrt/tags | grep -Eo "v[0-9\.]+\-*r*c*[0-9]*.tar.gz" | sed -n '/23.05/p' | sed -n 1p | sed 's/v//g' | sed 's/.tar.gz//g')"
wget https://downloads.openwrt.org/releases/${latest_version}/targets/armsr/armv8/packages/Packages.gz
zgrep -m 1 "Depends: kernel (=.*)$" Packages.gz | sed -e 's/.*-\(.*\))/\1/' > .vermagic
sed -i -e 's/^\(.\).*vermagic$/\1cp $(TOPDIR)\/.vermagic $(LINUX_DIR)\/.vermagic/' include/kernel-defaults.mk

### 预配置一些插件 ###
mkdir -p files
cp -rf ../files/init/* files/
mkdir -p files/etc/uci-defaults
cp -f ../patch/default-settings/openwrt-23.05/zzz-default-settings ./files/etc/uci-defaults/

find ./ -name *.orig | xargs rm -f
find ./ -name *.rej | xargs rm -f

exit 0
