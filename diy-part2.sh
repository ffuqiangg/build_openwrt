#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#

# Modify default IP
sed -i 's/192.168.1.1/192.168.1.99/g' package/base-files/files/bin/config_generate

# Set DISTRIB_REVISION
sed -i "s|DISTRIB_REVISION='.*'|DISTRIB_REVISION='R$(date +%Y.%m.%d)'|g" package/lean/default-settings/files/zzz-default-settings

# Change menu
sed -i "20c sed -i 's/\\\\\"nas\\\\\"/\\\\\"services\\\\\"/g' /usr/lib/lua/luci/controller/vsftpd.lua" package/lean/default-settings/files/zzz-default-settings
sed -i "20c sed -i 's/\\\\\"nas\\\\\"/\\\\\"services\\\\\"/g' /usr/lib/lua/luci/controller/filebrowser.lua" package/lean/default-settings/files/zzz-default-settings
sed -i "22c sed -i 's/\\\\\"nas\\\\\"/\\\\\"services\\\\\"/g' /usr/lib/lua/luci/controller/samba4.lua" package/lean/default-settings/files/zzz-default-settings
sed -i "28c sed -i 's/nas/services/g' /usr/lib/lua/luci/view/filebrowser/filebrowser_status.htm" package/lean/default-settings/files/zzz-default-settings

# Readd cpufreq for aarch64 & change menu
sed -i 's/LUCI_DEPENDS.*/LUCI_DEPENDS:=\@\(arm\|\|aarch64\)/g' package/lean/luci-app-cpufreq/Makefile
# sed -i 's/services/system/g'  package/lean/luci-app-cpufreq/luasrc/controller/cpufreq.lua

