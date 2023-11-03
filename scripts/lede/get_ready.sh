#!/bin/bash

# Change release.txt
sed -i "s/COMPILE_DATE/R$(date +%y.%m.%d)/g" config/lede/release.txt

# Clone source code
git clone -q --single-branch --depth 1 -b master https://github.com/coolsnowwolf/lede openwrt

cd openwrt

# Add luci-app-passwall
git clone --single-branch --depth 1 https://github.com/xiaorouji/openwrt-passwall.git package/luci-app-passwall
# Add luci-app-passwall2
# git clone --single-branch --depth=1 https://github.com/xiaorouji/openwrt-passwall2 package/luci-app-passwall2
# depends
git clone --single-branch --depth 1 https://github.com/xiaorouji/openwrt-passwall-packages.git  package/passwall-depends
# Add luci-app-filebrowser & change menu
git clone --depth 1 https://github.com/Lienol/openwrt-package.git && mv openwrt-package/luci-app-filebrowser package/ && rm -rf openwrt-package
sed -i -e 's/nas/services/g' -e 's/NAS/Services/g' package/luci-app-filebrowser/luasrc/controller/filebrowser.lua
sed -i 's/nas/services/g' package/luci-app-filebrowser/luasrc/view/filebrowser/download.htm
sed -i 's/nas/services/g' package/luci-app-filebrowser/luasrc/view/filebrowser/log.htm
sed -i 's/nas/services/g' package/luci-app-filebrowser/luasrc/view/filebrowser/status.htm
# Add luci-app-openclash
git clone --depth 1 --single-branch -b master https://github.com/vernesong/OpenClash package/luci-app-openclash
# Add luci-app-mosdns
find . | grep Makefile | grep v2ray-geodata | xargs rm -f
find . | grep Makefile | grep mosdns | xargs rm -f
git clone --depth=1 --single-branch -b v5 https://github.com/sbwml/luci-app-mosdns package/mosdns
git clone https://github.com/sbwml/v2ray-geodata package/v2ray-geodata

wait

# Modify default IP (FROM 192.168.1.1 CHANGE TO 192.168.1.99 )
sed -i 's/192.168.1.1/192.168.1.99/g' package/base-files/files/bin/config_generate
# Set DISTRIB_REVISION
sed -i "s,DISTRIB_REVISION='.*',DISTRIB_REVISION='R$(date +%y.%m.%d)',g" package/lean/default-settings/files/zzz-default-settings

./scripts/feeds update -a
./scripts/feeds install -a
