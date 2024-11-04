#!/bin/bash

source ../scripts/funcations.sh

### 基础部分 ###
# 使用 O2 级别的优化
sed -i 's/Os/O2/g' include/target.mk
# 更新 Feeds
./scripts/feeds update -a
./scripts/feeds install -a
# 默认开启 Irqbalance
sed -i "s/enabled '0'/enabled '1'/g" feeds/packages/utils/irqbalance/files/irqbalance.config

### 替换准备 ###
rm -rf feeds/packages/net/{xray-core,v2ray-core,v2ray-geodata,frp,shadowsocks-libev,v2raya}
rm -rf feeds/luci/applications/{luci-app-frps,luci-app-frpc,luci-app-v2raya}
rm -rf feeds/packages/utils/coremark

### 获取额外的 LuCI 应用和依赖 ###
mkdir -p ./package/new
# 替换 coremark
cp -rf ../openwrt_pkg_ma/utils/coremark ./feeds/packages/utils/coremark
# 预编译 node
rm -rf feeds/packages/lang/node
cp -rf ../node feeds/packages/lang/node
# Autocore
cp -rf ../lede/package/lean/autocore package/new/autocore
# Filebrowser 文件浏览器
cp -rf ../immortalwrt_luci_23/applications/luci-app-filebrowser ./package/new/luci-app-filebrowser
cp -rf ../immortalwrt_pkg/utils/filebrowser ./package/new/filebrowser
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
cp -rf ../immortalwrt_luci_23/applications/luci-app-vsftpd ./package/new/luci-app-vsftpd
cp -rf ../immortalwrt_pkg/net/vsftpd ./package/new/vsftpd
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
cp -rf ../immortalwrt_luci_23/applications/luci-app-cpufreq ./package/new/luci-app-cpufreq
sed -i 's,\"system\",\"services\",g' ./package/new/luci-app-cpufreq/root/usr/share/luci/menu.d/luci-app-cpufreq.json
# Sing-box
cp -rf ../immortalwrt_pkg/net/sing-box ./packages/new/sing-box
cp -f ../patch/sing-box/files/sing-box.init ./packages/new/sing-box/files/sing-box.init
# Golang
rm -rf ./feeds/packages/lang/golang
cp -rf ../openwrt_pkg_ma/lang/golang ./feeds/packages/lang/golang
# Passwall
cp -rf ../passwall_luci/luci-app-passwall ./package/new/luci-app-passwall
cp -rf ../passwall_pkg ./package/new/passwall_pkg
rm -rf ./package/new/passwall_pkg/{v2ray_geodata,shadowsocks-rust,sing-box}
cp -rf ../immortalwrt_pkg_21/net/shadowsocks-rust ./package/new/passwall_pkg/shadowsocks-rust
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
# Mosdns
cp -rf ../mosdns ./package/new/luci-app-mosdns
cp -rf ../v2ray_geodata ./feeds/packages/net/v2ray-geodata
# V2raya
git clone --depth 1 https://github.com/v2rayA/v2raya-openwrt.git luci-app-v2raya
cp -rf ./luci-app-v2raya/luci-app-v2raya ./feeds/luci/applications/luci-app-v2raya
cp -rf ./luci-app-v2raya/v2fly-geodata ./package/new/v2fly-geodata
rm -rf ./luci-app-v2raya
cp -rf ../openwrt_pkg_ma/net/v2raya ./feeds/packages/net/v2raya
ln -sf ../../../feeds/packages/net/v2raya ./package/feeds/packages/v2raya
# FRP 内网穿透
cp -rf ../immortalwrt_pkg/net/frp ./feeds/packages/net/frp
sed -i '/etc/d' feeds/packages/net/frp/Makefile
sed -i '/defaults/{N;d;}' feeds/packages/net/frp/Makefile
cp -rf ../lede_luci/applications/luci-app-frps ./package/new/luci-app-frps
cp -rf ../lede_luci/applications/luci-app-frpc ./package/new/luci-app-frpc

# 预配置一些插件
cp -rf ../patch/files ./files
sed -i 's,/bin/ash,/bin/bash,' ./package/base-files/files/etc/passwd && sed -i 's,/bin/ash,/bin/bash,' ./package/base-files/files/usr/libexec/login.sh
mkdir -p files/usr/share/xray
wget -qO- https://github.com/v2fly/geoip/releases/latest/download/geoip.dat >files/usr/share/xray/geoip.dat
wget -qO- https://github.com/v2fly/geoip/releases/latest/download/geosite.dat >files/usr/share/xray/geosite.dat

find ./ -name *.orig | xargs rm -f
find ./ -name *.rej | xargs rm -f

exit 0
