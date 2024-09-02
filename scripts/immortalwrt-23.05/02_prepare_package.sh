#!/bin/bash

. ../scripts/funcations.sh

### Prepare package
# 预编译 node
rm -rf feeds/packages/lang/node
cp -rf ../node feeds/packages/lang/node
# Luci-app-amlogic
git clone --depth 1 https://github.com/ophub/luci-app-amlogic.git ./package/luci-app-amlogic
# mount cgroupv2
pushd feeds/packages
patch -p1 <../../../patch/cgroupfs-mount/0001-fix-cgroupfs-mount.patch
popd
mkdir -p feeds/packages/utils/cgroupfs-mount/patches
cp -rf ../patch/cgroupfs-mount/900-mount-cgroup-v2-hierarchy-to-sys-fs-cgroup-cgroup2.patch ./feeds/packages/utils/cgroupfs-mount/patches/
cp -rf ../patch/cgroupfs-mount/901-fix-cgroupfs-umount.patch ./feeds/packages/utils/cgroupfs-mount/patches/
cp -rf ../patch/cgroupfs-mount/902-mount-sys-fs-cgroup-systemd-for-docker-systemd-suppo.patch ./feeds/packages/utils/cgroupfs-mount/patches/
# Wget
rm -rf ./feeds/packages/net/wget
cp -rf ../lede_pkg/net/wget ./feeds/packages/net/wget
# Mosdns
rm -rf ./feeds/packages/net/mosdns
cp -rf ../mosdns ./package/luci-app-mosdns
# samba4
sed -i 's,nas,services,g' package/feeds/luci/luci-app-samba4/root/usr/share/luci/menu.d/luci-app-samba4.json
# cpufreq
sed -i 's,system,services,g' package/feeds/luci/luci-app-cpufreq/root/usr/share/luci/menu.d/luci-app-cpufreq.json
# hd-idle
sed -i 's,nas,services,g' package/feeds/luci/luci-app-hd-idle/root/usr/share/luci/menu.d/luci-app-hd-idle.json
# vsftpd
pushd package/feeds/luci/luci-app-vsftpd
move_2_services nas
popd
# filebrowser
sed -i "s,PKG_VERSION:=.*,PKG_VERSION:=2\.27\.0," package/feeds/packages/filebrowser/Makefile
sed -i "s,PKG_HASH:=.*,PKG_HASH:=3a60cf26d6ded863d730bc671ee8df6dc342cab6dd867c16370eecb186fff655," package/feeds/packages/filebrowser/Makefile
# rclone
sed -i -e 's,\"nas\",\"services\",g' -e 's,NAS,Services,g' package/feeds/luci/luci-app-rclone/luasrc/controller/rclone.lua
# dockerman
pushd package/feeds/luci/luci-app-dockerman
docker_2_services
popd
# nlbw
sed -i 's,services,network,g' package/feeds/luci/luci-app-nlbwmon/root/usr/share/luci/menu.d/luci-app-nlbwmon.json
# verysync
pushd package/feeds/luci/luci-app-verysync
move_2_services nas
popd
# mihomo
cp -rf ../mihomo ./package/mihomo

# 预配置一些插件
cp -rf ../patch/files ./files
# mkdir -p files/etc/openclash/core
# pushd files/etc/openclash/core
# clash_version="$(curl -fsSL https://github.com/vernesong/OpenClash/raw/core/master/core_version | sed -n '2p')"
# wget https://github.com/vernesong/OpenClash/raw/core/master/premium/clash-linux-arm64-${clash_version}.gz -O clash_tun.gz && gzip -d clash_tun.gz
# wget https://github.com/vernesong/OpenClash/raw/core/master/meta/clash-linux-arm64.tar.gz -O clash_meta.tar.gz && tar -zxvf clash_meta.tar.gz && mv clash clash_meta
# wget https://github.com/vernesong/OpenClash/raw/core/master/dev/clash-linux-arm64.tar.gz -O clash.tar.gz && tar -zxvf clash.tar.gz
# chmod +x ./clash*
# find ./ -name "*.tar.gz" | xargs rm -f
# popd

chmod -R 755 ./
find ./ -name *.orig | xargs rm -f
find ./ -name *.rej | xargs rm -f

exit 0
