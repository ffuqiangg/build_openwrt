#!/bin/bash

source ../scripts/funcations.sh

### 基础部分 ###
# 使用 O2 级别的优化
sed -i 's/Os/O2/g' include/target.mk
# 默认开启 Irqbalance
sed -i "s/enabled '0'/enabled '1'/g" feeds/packages/utils/irqbalance/files/irqbalance.config

### 获取额外的 LuCI 应用和依赖 ###
mkdir -p ./package/new
# 预编译 node
rm -rf feeds/packages/lang/node
cp -rf ../node feeds/packages/lang/node
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
# # Passwall
# cp -rf ../immortalwrt_luci_21/applications/luci-app-passwall ./package/new/luci-app-passwall
# cp -rf ../immortalwrt_pkg_21/net/brook ./package/new/brook
# cp -rf ../immortalwrt_pkg_21/net/hysteria ./package/new/hysteria
# cp -rf ../immortalwrt_pkg_21/net/naiveproxy ./package/new/naiveproxy
# cp -rf ../immortalwrt_pkg_21/net/shadowsocks-rust ./package/new/shadowsocks-rust
# cp -rf ../immortalwrt_pkg_21/net/simple-obfs ./package/new/simple-obfs
# cp -rf ../immortalwrt_pkg_21/net/chinadns-ng ./package/new/chinadns-ng
cp -rf ../immortalwrt_pkg_21/devel/gn ./feeds/packages/devel/gn
ln -sf ../../../feeds/packages/devel/gn ./package/feeds/packages/gn
# Sing-box
rm -rf ./feeds/packages/net/sing-box
cp -rf ../immortalwrt_pkg/net/sing-box ./feeds/packages/net/sing-box
cp -f ../patch/sing-box/files/sing-box.init ./feeds/packages/net/sing-box/files/sing-box.init
sed -i '63i\GO_PKG_TARGET_VARS:=$(filter-out CGO_ENABLED=%,$(GO_PKG_TARGET_VARS)) CGO_ENABLED=1\n' ./feeds/packages/net/sing-box/Makefile
# Golang
rm -rf ./feeds/packages/lang/golang
cp -rf ../openwrt_pkg_ma/lang/golang ./feeds/packages/lang/golang
# Passwall
cp -rf ../passwall_luci/luci-app-passwall ./package/new/luci-app-passwall
cp -rf ../passwall_pkg/tcping ./package/new/tcping
cp -rf ../passwall_pkg/trojan-go ./package/new/trojan-go
cp -rf ../passwall_pkg/brook ./package/new/brook
cp -rf ../passwall_pkg/ssocks ./package/new/ssocks
cp -rf ../passwall_pkg/microsocks ./package/new/microsocks
cp -rf ../passwall_pkg/dns2socks ./package/new/dns2socks
cp -rf ../passwall_pkg/dns2tcp ./package/new/dns2tcp
cp -rf ../passwall_pkg/ipt2socks ./package/new/ipt2socks
cp -rf ../passwall_pkg/pdnsd-alt ./package/new/pdnsd-alt
cp -rf ../openwrt-add/trojan-plus ./package/new/trojan-plus
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

# 预配置一些插件
cp -rf ../patch/files ./files
sed -i 's,/bin/ash,/bin/bash,' ./package/base-files/files/etc/passwd && sed -i 's,/bin/ash,/bin/bash,' ./package/base-files/files/usr/libexec/login.sh
mkdir -p files/usr/share/xray
wget -qO- https://github.com/v2fly/geoip/releases/latest/download/geoip.dat > files/usr/share/xray/geoip.dat
wget -qO- https://github.com/v2fly/geoip/releases/latest/download/geosite.dat > files/usr/share/xray/geosite.dat

chmod -R 755 ./
find ./ -name *.orig | xargs rm -f
find ./ -name *.rej | xargs rm -f

exit 0
