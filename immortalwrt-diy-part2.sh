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

# Add packages
# git clone https://github.com/QiuSimons/openwrt-mos package/luci-app-mosdns

# Set DISTRIB_REVISION
# sed -i "s|DISTRIB_REVISION='.*'|DISTRIB_REVISION='R$(date +%y.%m.%d)'|g" package/lean/default-settings/files/zzz-default-settings

# Change menu
sed -i '/dispatcher.lua/a\sed -i '\''s/nas/services/g'\'' /usr/lib/lua/luci/view/filebrowser/filebrowser_status.htm' package/emortal/default-settings/files/99-default-settings
sed -i '/dispatcher.lua/a\sed -i '\''s/\\\"nas\\\"/\\\"services\\\"/g'\'' /usr/lib/lua/luci/controller/filebrowser.lua' package/emortal/default-settings/files/99-default-settings
sed -i '/dispatcher.lua/a\sed -i '\''s/\\\"nas\\\"/\\\"services\\\"/g'\'' /usr/lib/lua/luci/controller/samba4.lua' package/emortal/default-settings/files/99-default-settings
sed -i '/dispatcher.lua/a\sed -i '\''s/\\\"system\\\"/\\\"services\\\"/g'\'' /usr/lib/lua/luci/controller/cpufreq.lua' package/emortal/default-settings/files/99-default-settings
sed -i '/dispatcher.lua/a\sed -i '\''s/\\\"nas\\\"/\\\"services\\\"/g'\'' /usr/lib/lua/luci/controller/hd_idle.lua' package/emortal/default-settings/files/99-default-settings
sed -i '/dispatcher.lua/a\sed -i '\''s/\\\"nas\\\"/\\\"services\\\"/g'\'' /usr/lib/lua/luci/controller/vsftpd.lua' package/emortal/default-settings/files/99-default-settings
 
./scripts/feeds update -a
./scripts/feeds install -a
