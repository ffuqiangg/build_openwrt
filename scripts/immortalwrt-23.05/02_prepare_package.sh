#!/bin/bash

source ../scripts/funcations.sh

### 基础部分 ###
# 使用 O2 级别的优化
sed -i 's/Os/O2/g' include/target.mk
# 更新 Feeds
./scripts/feeds update -a
./scripts/feeds install -a
# 移除 SNAPSHOT 标签
sed -i 's,-SNAPSHOT,,g' include/version.mk
sed -i 's,-SNAPSHOT,,g' package/base-files/image-config.in

### 替换准备 ###
rm -rf feeds/packages/net/{wget,v2ray-geodata,mosdns}

### 额外的 LuCI 应用和依赖 ###
mkdir -p package/new
# 调整 default settings
patch -p1 < ../patch/default-settings/immortalwrt-23.05/01_modify_immortalwrt-23.05_default-settings.patch
# 预编译 node
rm -rf ./feeds/patches/lang/node
cp -rf ../node ./feeds/package/lang/node
# 更换 golang 版本
rm -rf ./feeds/packages/lang/golang
cp -rf ../openwrt_pkg_ma/lang/golang ./feeds/packages/lang/golang
# Luci-app-amlogic
git clone --depth 1 https://github.com/ophub/luci-app-amlogic.git ./package/new/luci-app-amlogic
# mount cgroupv2
pushd feeds/packages
patch -p1 < ../../../patch/cgroupfs-mount/0001-fix-cgroupfs-mount.patch
popd
mkdir -p feeds/packages/utils/cgroupfs-mount/patches
cp -rf ../patch/cgroupfs-mount/900-mount-cgroup-v2-hierarchy-to-sys-fs-cgroup-cgroup2.patch ./feeds/packages/utils/cgroupfs-mount/patches/
cp -rf ../patch/cgroupfs-mount/901-fix-cgroupfs-umount.patch ./feeds/packages/utils/cgroupfs-mount/patches/
cp -rf ../patch/cgroupfs-mount/902-mount-sys-fs-cgroup-systemd-for-docker-systemd-suppo.patch ./feeds/packages/utils/cgroupfs-mount/patches/
# Wget
cp -rf ../lede_pkg/net/wget ./feeds/packages/net/wget
# Mosdns
cp -rf ../mosdns ./package/new/luci-app-mosdns
cp -rf ../v2ray_geodata feeds/packages/net/v2ray-geodata
# Samba4
sed -i 's,nas,services,g' feeds/luci/applications/luci-app-samba4/root/usr/share/luci/menu.d/luci-app-samba4.json
# Cpufreq
sed -i 's,system,services,g' feeds/luci/applications/luci-app-cpufreq/root/usr/share/luci/menu.d/luci-app-cpufreq.json
# HD-idle
sed -i 's,nas,services,g' feeds/luci/applications/luci-app-hd-idle/root/usr/share/luci/menu.d/luci-app-hd-idle.json
# Vsftpd
pushd feeds/luci/applications/luci-app-vsftpd
move_2_services nas
popd
# Filebrowser
sed -i "s,PKG_VERSION:=.*,PKG_VERSION:=2\.31\.2," feeds/packages/utils/filebrowser/Makefile
sed -i "s,PKG_HASH:=.*,PKG_HASH:=bfda9ea7c44d4cb93c47a007c98b84f853874e043049b44eff11ca00157d8426," feeds/packages/utils/filebrowser/Makefile
# Rclone
sed -i -e 's,\"nas\",\"services\",g' -e 's,NAS,Services,g' feeds/luci/applications/luci-app-rclone/luasrc/controller/rclone.lua
# Dockerman
pushd feeds/luci/applications/luci-app-dockerman
docker_2_services
popd
# Nlbw
sed -i 's,services,network,g' feeds/luci/applications/luci-app-nlbwmon/root/usr/share/luci/menu.d/luci-app-nlbwmon.json
# Verysync
pushd feeds/luci/applications/luci-app-verysync
move_2_services nas
popd
# Mihomo
cp -rf ../mihomo ./package/mihomo

# 预配置一些插件
mkdir -p files
cp -rf ../files/{etc,root} files/

find ./ -name *.orig | xargs rm -f
find ./ -name *.rej | xargs rm -f

exit 0
