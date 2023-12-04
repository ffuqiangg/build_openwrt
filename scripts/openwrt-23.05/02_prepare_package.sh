#!/bin/bash

./scripts/feeds update -a
./scripts/feeds install -a

### 获取额外的 LuCI 应用、主题和依赖 ###
# AutoCore
mkdir -p package/new
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
# ChinaDNS
git clone -b luci --depth 1 https://github.com/QiuSimons/openwrt-chinadns-ng.git package/new/luci-app-chinadns-ng
cp -rf ../passwall_pkg/chinadns-ng ./package/new/chinadns-ng
# Docker 容器
rm -rf ./feeds/luci/applications/luci-app-dockerman
cp -rf ../dockerman/applications/luci-app-dockerman ./feeds/luci/applications/luci-app-dockerman
sed -i -e 's|admin\",|& \"services\",|g' -e 's,Docker,&Man,' -e 's,config\"),overview\"),' ./feeds/luci/applications/luci-app-dockerman/luasrc/controller/dockerman.lua
sed -i 's,admin/,&services/,g' ./feeds/luci/applications/luci-app-dockerman/luasrc/model/cbi/dockerman/container.lua
sed -i 's,admin/,&services/,g' ./feeds/luci/applications/luci-app-dockerman/luasrc/model/cbi/dockerman/containers.lua
sed -i 's,admin/,&services/,g' ./feeds/luci/applications/luci-app-dockerman/luasrc/model/cbi/dockerman/images.lua
sed -i 's,admin/,&services/,g' ./feeds/luci/applications/luci-app-dockerman/luasrc/model/cbi/dockerman/networks.lua
sed -i -e 's,admin/,&services/,g' -e 's|admin\",|& \"services\",|g' ./feeds/luci/applications/luci-app-dockerman/luasrc/model/cbi/dockerman/newcontainer.lua
sed -i -e 's,admin/,&services/,g' -e 's|admin\",|& \"services\",|g' ./feeds/luci/applications/luci-app-dockerman/luasrc/model/cbi/dockerman/newnetwork.lua
sed -i 's,admin/,&services/,g' ./feeds/luci/applications/luci-app-dockerman/luasrc/model/cbi/dockerman/overview.lua
sed -i 's,admin/,&services/,g' ./feeds/luci/applications/luci-app-dockerman/luasrc/model/cbi/dockerman/volumes.lua
sed -i 's,admin/,&services/,g' ./feeds/luci/applications/luci-app-dockerman/luasrc/view/dockerman/apply_widget.htm
sed -i -e 's,admin/,&services/,g' -e 's,admin\\/,&services\\/,g' ./feeds/luci/applications/luci-app-dockerman/luasrc/view/dockerman/container.htm
sed -i 's,admin/,&services/,g' ./feeds/luci/applications/luci-app-dockerman/luasrc/view/dockerman/container_file_manager.htm
sed -i 's,admin/,&services/,g' ./feeds/luci/applications/luci-app-dockerman/luasrc/view/dockerman/container_stats.htm
sed -i 's,admin/,&services/,g' ./feeds/luci/applications/luci-app-dockerman/luasrc/view/dockerman/containers_running_stats.htm
sed -i 's,admin/,&services/,g' ./feeds/luci/applications/luci-app-dockerman/luasrc/view/dockerman/images_import.htm
sed -i 's,admin/,&services/,g' ./feeds/luci/applications/luci-app-dockerman/luasrc/view/dockerman/images_load.htm
sed -i 's,admin/,&services/,g' ./feeds/luci/applications/luci-app-dockerman/luasrc/view/dockerman/newcontainer_resolve.htm
sed -i 's,admin/,&services/,g' ./feeds/luci/applications/luci-app-dockerman/luasrc/view/dockerman/overview.htm
sed -i 's,admin/,&services/,g' ./feeds/luci/applications/luci-app-dockerman/luasrc/view/dockerman/volume_size.htm
sed -i '/auto_start/d' ./feeds/luci/applications/luci-app-dockerman/root/etc/uci-defaults/luci-app-dockerman
pushd feeds/packages
wget -qO- https://github.com/openwrt/packages/commit/e2e5ee69.patch | patch -p1
wget -qO- https://github.com/openwrt/packages/pull/20054.patch | patch -p1
popd
sed -i '/sysctl.d/d' ./feeds/packages/utils/dockerd/Makefile
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
sed -i '/etc/d' ./feeds/packages/net/frp/Makefile
sed -i '/defaults/{N;d;}' ./feeds/packages/net/frp/Makefile
cp -rf ../lede_luci/applications/luci-app-frps ./feeds/luci/applications/luci-app-frps
cp -rf ../lede_luci/applications/luci-app-frpc ./feeds/luci/applications/luci-app-frpc
# 晶晨宝盒
git clone --depth 1 https://github.com/ophub/luci-app-amlogic.git ./package/new/luci-app-amlogic
# Mosdns
cp -rf ../mosdns/mosdns ./package/new/mosdns
cp -rf ../mosdns/luci-app-mosdns ./package/new/luci-app-mosdns
rm -rf ./feeds/packages/net/v2ray-geodata
cp -rf ../mosdns/v2ray-geodata ./package/new/v2ray-geodata
# homeproxy
git clone --single-branch --depth 1 -b dev https://github.com/immortalwrt/homeproxy.git ./package/new/luci-app-homeproxy
rm -rf ./feeds/packages/net/sing-box
cp -rf ../immortalwrt_pkg/net/sing-box ./feeds/packages/net/sing-box
# OpenClash
git clone --single-branch --depth 1 -b master https://github.com/vernesong/OpenClash.git ./package/new/luci-app-openclash
# Passwall
cp -rf ../passwall_luci/luci-app-passwall ./package/new/luci-app-passwall
pushd package/new/luci-app-passwall
bash ../../../../scripts/move_2_services.sh vpn
popd
cp -rf ../passwall_pkg ./package/new/passwall_pkg
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
cp -rf ../lede_luci/applications/luci-app-ramfree ./package/new/luci-app-ramfree
# KMS 激活助手
cp -rf ../lede_luci/applications/luci-app-vlmcsd ./package/new/luci-app-vlmcsd
cp -rf ../lede_pkg/net/vlmcsd ./package/new/vlmcsd
# Vsftpd
cp -rf ../immortalwrt_luci_23/applications/luci-app-vsftpd ./package/new/luci-app-vsftpd
pushd package/new/luci-app-vsftpd
bash ../../../../scripts/move_2_services.sh nas
popd
# Filebrowser 文件浏览器
cp -rf ../Lienol_pkg/luci-app-filebrowser ./package/new/luci-app-filebrowser
pushd package/new/luci-app-filebrowser
bash ../../../../scripts/move_2_services.sh nas
popd
# Filetransfer
cp -rf ../immortalwrt_luci_23/applications/luci-app-filetransfer ./package/new/luci-app-filetransfer
cp -rf ../immortalwrt_luci_23/libs/luci-lib-fs ./package/new/luci-lib-fs
# nlbw
sed -i 's,services,network,g' package/feeds/luci/luci-app-nlbwmon/root/usr/share/luci/menu.d/luci-app-nlbwmon.json

### 最后的收尾工作 ###
# 处理 Makefile 文件
makefile_file="$({ find package -type f | grep Makefile | sed "/Makefile./d"; } 2>"/dev/null")"
for a in ${makefile_file}; do
    [ -n "$(grep "luci.mk" "$a")" ] && sed -i "s|\.\./\.\.|$\(TOPDIR\)/feeds/luci|g" "$a"
done
# 生成默认配置及缓存
rm -rf .config
sed -i 's,CONFIG_WERROR=y,# CONFIG_WERROR is not set,g' target/linux/generic/config-5.15

exit 0
