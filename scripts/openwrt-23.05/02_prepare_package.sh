#!/bin/bash

source ../scripts/funcations.sh

### 基础部分 ###
# 使用 O2 级别的优化
sed -i 's/Os/O2/g' include/target.mk
# 更新 Feeds
./scripts/feeds update -a
./scripts/feeds install -a

### FIREWALL ###
# custom nft command
patch -p1 < ../patch/firewall/100-openwrt-firewall4-add-custom-nft-command-support.patch
# patch LuCI 以支持自定义 nft 规则
pushd feeds/luci
patch -p1 < ../../../patch/firewall/04-luci-add-firewall4-nft-rules-file.patch
popd

### 替换准备 ###
rm -rf feeds/packages/net/{xray-core,v2ray-core,v2ray-geodata,sing-box,microsocks,shadowsocks-libev,v2raya}

### 获取额外的 LuCI 应用和依赖 ###
mkdir -p ./package/new
# 预编译 node
rm -rf ./feeds/packages/lang/node
cp -rf ../node ./feeds/packages/lang/node
# 更换 golang 版本
rm -rf ./feeds/packages/lang/golang
cp -rf ../openwrt_pkg_ma/lang/golang ./feeds/packages/lang/golang
# Autocore
cp -rf ../files/autocore ./package/new/autocore
# mount cgroupv2
pushd feeds/packages
patch -p1 < ../../../patch/cgroupfs-mount/0001-fix-cgroupfs-mount.patch
popd
mkdir -p feeds/packages/utils/cgroupfs-mount/patches
cp -rf ../patch/cgroupfs-mount/900-mount-cgroup-v2-hierarchy-to-sys-fs-cgroup-cgroup2.patch ./feeds/packages/utils/cgroupfs-mount/patches/
cp -rf ../patch/cgroupfs-mount/901-fix-cgroupfs-umount.patch ./feeds/packages/utils/cgroupfs-mount/patches/
cp -rf ../patch/cgroupfs-mount/902-mount-sys-fs-cgroup-systemd-for-docker-systemd-suppo.patch ./feeds/packages/utils/cgroupfs-mount/patches/
# Passwall
cp -rf ../passwall_luci/luci-app-passwall ./package/new/luci-app-passwall
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
' >> package/new/luci-app-passwall/root/usr/share/passwall/rules/direct_host
# Passwall package
cp -rf ../passwall_pkg ./package/new/passwall_pkg
# CPU 占用率限制
cp -rf ../immortalwrt_luci_23/applications/luci-app-cpulimit ./package/new/luci-app-cpulimit
sed -i "s|\.\./\.\.|$\(TOPDIR\)/feeds/luci|g" package/new/luci-app-cpulimit/Makefile
cp -rf ../immortalwrt_pkg/utils/cpulimit ./package/new/cpulimit
# Filebrowser 文件浏览器
cp -rf ../immortalwrt_luci_23/applications/luci-app-filebrowser ./package/new/luci-app-filebrowser
sed -i "s|\.\./\.\.|$\(TOPDIR\)/feeds/luci|g" package/new/luci-app-filebrowser/Makefile
cp -rf ../immortalwrt_pkg/utils/filebrowser ./package/new/filebrowser
sed -i "s|\.\./\.\.|$\(TOPDIR\)/feeds/packages|g" package/new/filebrowser/Makefile
pushd package/new/luci-app-filebrowser
move_2_services nas
popd
# DAED
git clone --depth 1 -b master https://github.com/QiuSimons/luci-app-daed.git package/new/luci-app-daed
cp -rf ../immortalwrt_pkg/libs/libcron ./package/new/libcron
# Docker 容器
rm -rf ./feeds/luci/applications/luci-app-dockerman
cp -rf ../dockerman/applications/luci-app-dockerman ./feeds/luci/applications/luci-app-dockerman
sed -i '/auto_start/d' feeds/luci/applications/luci-app-dockerman/root/etc/uci-defaults/luci-app-dockerman
rm -rf ./feeds/luci/collections/luci-lib-docker
cp -rf ../docker_lib/collections/luci-lib-docker ./feeds/luci/collections/luci-lib-docker
# MosDNS
cp -rf ../mosdns ./package/new/luci-app-mosdns
# Mosdns 白名单
echo 'account.synology.com
ddns.synology.com
checkip.synology.com
checkip.dyndns.org
checkipv6.synology.com
ntp.aliyun.com
cn.ntp.org.cn
ntp.ntsc.ac.cn' >> package/new/luci-app-mosdns/luci-app-mosdns/root/etc/mosdns/rule/whitelist.txt
cp -rf ../v2ray_geodata ./package/new/v2ray-geodata
# V2raya
git clone --depth 1 https://github.com/v2rayA/v2raya-openwrt.git v2raya
cp -rf ./v2raya/luci-app-v2raya ./package/new/luci-app-v2raya
rm -rf ./v2raya
cp -rf ../openwrt_pkg_ma/net/v2raya ./feeds/packages/net/v2raya
# FTP 服务器
cp -rf ../immortalwrt_luci_23/applications/luci-app-vsftpd ./package/new/luci-app-vsftpd
sed -i "s|\.\./\.\.|$\(TOPDIR\)/feeds/luci|g" package/new/luci-app-vsftpd/Makefile
cp -rf ../immortalwrt_pkg/net/vsftpd ./package/new/vsftpd
pushd package/new/luci-app-vsftpd
move_2_services nas
popd
# nlbw
sed -i 's,services,network,g' package/feeds/luci/luci-app-nlbwmon/root/usr/share/luci/menu.d/luci-app-nlbwmon.json
# ttyd
sed -i 's,services,system,g' package/feeds/luci/luci-app-ttyd/root/usr/share/luci/menu.d/luci-app-ttyd.json
# Verysync
cp -rf ../immortalwrt_luci_23/applications/luci-app-verysync ./package/new/luci-app-verysync
sed -i "s|\.\./\.\.|$\(TOPDIR\)/feeds/luci|g" package/new/luci-app-verysync/Makefile
cp -rf ../immortalwrt_pkg/net/verysync ./package/new/verysync
pushd package/new/luci-app-verysync
move_2_services nas
popd
# KMS 服务器
cp -rf ../immortalwrt_luci_23/applications/luci-app-vlmcsd ./package/new/luci-app-vlmcsd
sed -i "s|\.\./\.\.|$\(TOPDIR\)/feeds/luci|g" package/new/luci-app-vlmcsd/Makefile 
cp -rf ../immortalwrt_pkg/net/vlmcsd ./package/new/vlmcsd
# 晶晨宝盒
git clone --depth 1 https://github.com/ophub/luci-app-amlogic.git package/new/luci-app-amlogic
# DDNS scripts
cp -rf ../immortalwrt_pkg/net/ddns-scripts_dnspod ./package/new/ddns-scripts_dnspod
cp -rf ../immortalwrt_pkg/net/ddns-scripts_aliyun ./package/new/ddns-scripts_aliyun
# default settings
cp -rf ../files/default-settings ./package/new/default-settings
# mihomo
cp -rf ../mihomo ./package/new/luci-app-mihomo

### 预配置一些插件 ###
mkdir -p files
cp -rf ../files/{etc,root,sing-box/*} files/

find ./ -name *.orig | xargs rm -f
find ./ -name *.rej | xargs rm -f

exit 0
