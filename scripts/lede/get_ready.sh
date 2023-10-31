#!/bin/bash

repo_url="https://github.com/coolsnowwolf/lede"
repo_branch="master"

# Clone Wrt source code
git clone -q --single-branch --depth=1 -b ${repo_branch} ${repo_url} openwrt
# Add passwall
# git clone --single-branch -b luci --depth=1 https://github.com/xiaorouji/openwrt-passwall.git openwrt/package/luci-app-passwall
# Add passwall2
git clone --single-branch --depth=1 https://github.com/xiaorouji/openwrt-passwall2 openwrt/package/luci-app-passwall2
# depends
git clone --single-branch --depth=1 https://github.com/xiaorouji/openwrt-passwall.git  openwrt/package/passwall-depends
# Add filebrowser & change menu
git clone --depth 1 https://github.com/Lienol/openwrt-package.git && mv openwrt-package/luci-app-filebrowser openwrt/package/ && rm -rf openwrt-package
sed -i -e 's/nas/services/g' -e 's/NAS/Services/g' openwrt/package/luci-app-filebrowser/luasrc/controller/filebrowser.lua
sed -i 's/nas/services/g' openwrt/package/luci-app-filebrowser/luasrc/view/filebrowser/download.htm
sed -i 's/nas/services/g' openwrt/package/luci-app-filebrowser/luasrc/view/filebrowser/log.htm
sed -i 's/nas/services/g' openwrt/package/luci-app-filebrowser/luasrc/view/filebrowser/status.htm
# Add luci-app-openclash
git clone https://github.com/vernesong/OpenClash openwrt/package/luci-app-openclash
# Add luci-app-mosdns
find ./openwrt | grep Makefile | grep v2ray-geodata | xargs rm -f
find ./openwrt | grep Makefile | grep mosdns | xargs rm -f
git clone --depth=1 --single-branch -b v5 https://github.com/sbwml/luci-app-mosdns openwrt/package/mosdns
git clone https://github.com/sbwml/v2ray-geodata openwrt/package/v2ray-geodata

wait

# Some settings
# Modify default IP (FROM 192.168.1.1 CHANGE TO 192.168.1.99 )
sed -i 's/192.168.1.1/192.168.1.99/g' openwrt/package/base-files/files/bin/config_generate
# Set DISTRIB_REVISION
sed -i "s,DISTRIB_REVISION='.*',DISTRIB_REVISION='R$(date +%y.%m.%d)',g" openwrt/package/lean/default-settings/files/zzz-default-settings
# Write release.txt
sed -i "s/COMPILE_DATE/R$(date +%y.%m.%d)/g" init.sh

# Set output information
echo "IMAGE_NAME=lede" >> ${GITHUB_ENV}
echo "PACKAGE_REPO=flippy" >> ${GITHUB_ENV}
echo "MAKE_SH=mk_lede_n1.sh" >> ${GITHUB_ENV}
echo "DISTRIB_DES=Openwrt" >> ${GITHUB_ENV}
echo "KERNEL_VERSION=5.15.1" >> ${GITHUB_ENV}
echo "KERNEL_REPO=breakings/Openwrt" >> ${GITHUB_ENV}
echo "COMPILE_DATE=R$(date +%y.%m.%d)" >> ${GITHUB_ENV}
