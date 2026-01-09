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

### 获取额外的 LuCI 应用和依赖 ###
mkdir -p ./package/new
cp -rf ../sbwml_pkgs/{luci-app-diskman,luci-app-autoreboot} ./package/new/
# 调整刷机脚本
patch -p1 < ../patch/custom_install/istoreos/custom_target_amlogic_scripts.patch
# 调整 default settings
sed -i '/dockerd.globals.data_root/d' package/istoreos-files/files/etc/uci-defaults/09_istoreos
sed -i 'N;/\n.*commit dockerd/!P;D' package/istoreos-files/files/etc/uci-defaults/09_istoreos 
sed -i '/commit dockerd/{N;d;}' package/istoreos-files/files/etc/uci-defaults/09_istoreos
sed -i '/exit/d' package/istoreos-files/files/etc/uci-defaults/09_istoreos
cat <<-EOF >> package/istoreos-files/files/etc/uci-defaults/09_istoreos
sed -i '/BUILD_DATE/d' /etc/openwrt_release
echo "BUILD_DATE='$1'" >> /etc/openwrt_release

exit 0
EOF
# 一些补充翻译
cp -rf ../patch/addition-trans-zh ./package/new/
# Golang
rm -rf ./feeds/packages/lang/golang
cp -rf ../openwrt_pkg_ma/lang/golang ./feeds/packages/lang/golang
# 预编译 node
rm -rf feeds/packages/lang/node/*
wget https://raw.githubusercontent.com/sbwml/feeds_packages_lang_node-prebuilt/packages-22.03/Makefile -O feeds/packages/lang/node/Makefile
# mount cgroupv2
pushd feeds/packages
patch -p1 < ../../../patch/cgroupfs-mount/0001-fix-cgroupfs-mount.patch
popd
mkdir -p feeds/packages/utils/cgroupfs-mount/patches
cp -rf ../patch/cgroupfs-mount/900-mount-cgroup-v2-hierarchy-to-sys-fs-cgroup-cgroup2.patch ./feeds/packages/utils/cgroupfs-mount/patches/
cp -rf ../patch/cgroupfs-mount/901-fix-cgroupfs-umount.patch ./feeds/packages/utils/cgroupfs-mount/patches/
cp -rf ../patch/cgroupfs-mount/902-mount-sys-fs-cgroup-systemd-for-docker-systemd-suppo.patch ./feeds/packages/utils/cgroupfs-mount/patches/
# Autocore
cp -rf ../autocore ./package/new/autocore-arm
sed -i 's/?/ARMv8 Processor/' package/new/autocore-arm/files/generic/cpuinfo
# IP/MAC 绑定
cp -rf ../immortalwrt_luci_ma/applications/luci-app-arpbind ./package/new/luci-app-arpbind
sed -i 's|\.\./\.\.|$(TOPDIR)/feeds/luci|g' package/new/luci-app-arpbind/Makefile
# CPU 限制
cp -rf ../immortalwrt_luci_ma/applications/luci-app-cpulimit ./package/new/luci-app-cpulimit
sed -i 's|\.\./\.\.|$(TOPDIR)/feeds/luci|g' package/new/luci-app-cpulimit/Makefile
cp -rf ../immortalwrt_pkg_ma/utils/cpulimit ./package/new/cpulimit
# Frpc
rm -rf ./feeds/luci/applications/{luci-app-frps,luci-app-frpc} ./feeds/packages/net/frp
cp -rf ../lede_luci_ma/applications/{luci-app-frps,luci-app-frpc} ./feeds/luci/applications/
cp -rf ../immortalwrt_pkg_ma/net/frp ./feeds/packages/net/frp
# 替换 sing-box
cp -rf ../immortalwrt_pkg_ma/net/sing-box ./package/new/sing-box
sed -i 's|\.\./\.\.|$(TOPDIR)/feeds/packages|g' package/new/sing-box/Makefile
# MosDNS
rm -rf ./feeds/packages/net/v2ray-geodata
cp -rf ../openwrt-add/luci-app-mosdns ./package/new/luci-app-mosdns
cp -rf ../v2ray_geodata ./package/new/v2ray-geodata
echo 'account.synology.com
ddns.synology.com
checkip.synology.com
checkip.dyndns.org
checkipv6.synology.com
ntp.aliyun.com
cn.ntp.org.cn
ntp.ntsc.ac.cn' >> package/new/luci-app-mosdns/luci-app-mosdns/root/etc/mosdns/rule/whitelist.txt
# Docker 容器
rm -rf ./feeds/luci/applications/luci-app-dockerman
cp -rf ../dockerman/applications/luci-app-dockerman ./package/new/luci-app-dockerman
sed -i '/auto_start/d' package/new/luci-app-dockerman/root/etc/uci-defaults/luci-app-dockerman
pushd package/new/luci-app-dockerman
docker_to_services
popd
# Passwall
rm -rf feeds/packages/net/{shadowsocks-libev,v2ray-core,xray-core}
cp -rf ../openwrt-add/openwrt_helloworld ./package/new/
rm -rf ./package/new/openwrt-add/openwrt_helloworld/v2ray-geodata
sed -i '/select PACKAGE_geoview/{n;s/default n/default y/;}' package/new/openwrt_helloworld/luci-app-passwall/Makefile
sed -i 's, +libopenssl-legacy,,g' package/new/openwrt_helloworld/shadowsocksr-libev/Makefile
# V2raya
rm -rf ./feeds/luci/applications/luci-app-v2raya ./feeds/packages/net/v2raya
cp -rf ../immortalwrt_luci_ma/applications/luci-app-v2raya ./feeds/luci/applications/luci-app-v2raya
cp -rf ../immortalwrt_pkg_ma/net/v2raya ./feeds/packages/net/v2raya
# OpenClash
cp -rf ../openwrt-add/OpenClash ./package/new/luci-app-openclash
# Nlbw 带宽监控
sed -i 's,services,network,g' feeds/luci/applications/luci-app-nlbwmon/root/usr/share/luci/menu.d/luci-app-nlbwmon.json
sed -i 's,services,network,g' feeds/luci/applications/luci-app-nlbwmon/htdocs/luci-static/resources/view/nlbw/config.js
# 终端 TTYD
sed -i 's,services,system,g' feeds/luci/applications/luci-app-ttyd/root/usr/share/luci/menu.d/luci-app-ttyd.json
# Coremark
rm -rf ./feeds/packages/utils/coremark
cp -rf ../sbwml_pkgs/coremark ./package/new/
# Curl
rm -rf ./feeds/packages/net/curl
cp -rf ../immortalwrt_pkg_ma/net/curl ./feeds/packages/net/curl
cp -rf ../immortalwrt_pkg_ma/libs/{nghttp3,ngtcp2} ./package/new/
# Cpufreq
cp -rf ../immortalwrt_luci_21/applications/luci-app-cpufreq package/new/luci-app-cpufreq
sed -i 's|\.\./\.\.|$(TOPDIR)/feeds/luci|g' package/new/luci-app-cpufreq/Makefile
# Filebrowser 文件管理器
cp -rf ../sbwml_pkgs/{luci-app-filebrowser-go,filebrowser} ./package/new/
# FTP 服务器
rm -rf ./feeds/packages/net/vsftpd
cp -rf ../immortalwrt_luci_21/applications/luci-app-vsftpd ./package/new/luci-app-vsftpd
sed -i 's|\.\./\.\.|$(TOPDIR)/feeds/luci|g' package/new/luci-app-vsftpd/Makefile
cp -rf ../immortalwrt_pkg_21/net/vsftpd ./feeds/packages/net/vsftpd

# 预配置一些插件
sed -i 's,/bin/ash,/bin/bash,' package/base-files/files/etc/passwd
sed -i 's,/bin/ash,/bin/bash,' package/base-files/files/usr/libexec/login.sh
mkdir -p ./files/etc/uci-defaults ./files/etc/openclash/core
cp -rf ../files/{init/*,cpufreq/*} ./files/
cp -f ../patch/default-settings/istoreos/zzz-default-settings ./files/etc/uci-defaults/
wget -qO- https://github.com/vernesong/OpenClash/raw/core/master/meta/clash-linux-arm64.tar.gz | tar xOvz > files/etc/openclash/core/clash_meta
chmod +x files/etc/openclash/core/clash*

# 清理临时文件
find ./ -name *.orig | xargs rm -f
find ./ -name *.rej | xargs rm -f

exit 0
