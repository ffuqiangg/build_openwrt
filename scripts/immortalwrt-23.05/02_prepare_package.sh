#!/bin/bash

. ../scripts/funcations.sh

### 基础部分 ###
# 使用 O2 级别的优化
sed -i 's/Os/O2/g' include/target.mk
# 默认开启 Irqbalance
sed -i "s/enabled '0'/enabled '1'/g" feeds/packages/utils/irqbalance/files/irqbalance.config

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
# Golang
rm -rf ./feeds/packages/lang/golang
cp -rf ../openwrt_pkg_ma/lang/golang ./feeds/packages/lang/golang
# Mosdns
rm -rf ./feeds/packages/net/mosdns
cp -rf ../mosdns/mosdns ./package/mosdns
cp -rf ../mosdns/luci-app-mosdns ./package/luci-app-mosdns
rm -rf ./feeds/packages/net/v2ray-geodata
cp -rf ../mosdns/v2ray-geodata ./package/v2ray-geodata
# Samba4
sed -i 's,nas,services,g' package/feeds/luci/luci-app-samba4/root/usr/share/luci/menu.d/luci-app-samba4.json
# Cpufreq
sed -i 's,system,services,g' package/feeds/luci/luci-app-cpufreq/root/usr/share/luci/menu.d/luci-app-cpufreq.json
# HD-idle
sed -i 's,nas,services,g' package/feeds/luci/luci-app-hd-idle/root/usr/share/luci/menu.d/luci-app-hd-idle.json
# Vsftpd
pushd package/feeds/luci/luci-app-vsftpd
move_2_services nas
popd
# Filebrowser
sed -i "s,PKG_VERSION:=.*,PKG_VERSION:=2\.31\.1," package/feeds/packages/filebrowser/Makefile
sed -i "s,PKG_HASH:=.*,PKG_HASH:=5917529F03F88AB3128C89C330BD9EABFADC05CF4179887FF3BA04A111888E49," package/feeds/packages/filebrowser/Makefile
# Rclone
sed -i -e 's,\"nas\",\"services\",g' -e 's,NAS,Services,g' package/feeds/luci/luci-app-rclone/luasrc/controller/rclone.lua
# Dockerman
pushd package/feeds/luci/luci-app-dockerman
docker_2_services
popd
# Nlbw
sed -i 's,services,network,g' package/feeds/luci/luci-app-nlbwmon/root/usr/share/luci/menu.d/luci-app-nlbwmon.json
# Verysync
pushd package/feeds/luci/luci-app-verysync
move_2_services nas
popd
# Mihomo
cp -rf ../mihomo ./package/mihomo

# 预配置一些插件
cp -rf ../patch/files ./files

chmod -R 755 ./
find ./ -name *.orig | xargs rm -f
find ./ -name *.rej | xargs rm -f

exit 0
