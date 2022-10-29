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

# Modify menu
sed -i '/dispatcher.lua/i\sed -i '\''s/\\\"nas\\\"/\\\"services\\\"/g'\'' /usr/lib/lua/luci/controller/samba4.lua' package/emortal/default-settings/files/99-default-settings
sed -i '/dispatcher.lua/i\sed -i '\''s/\\\"system\\\"/\\\"services\\\"/g'\'' /usr/lib/lua/luci/controller/cpufreq.lua' package/emortal/default-settings/files/99-default-settings
sed -i '/dispatcher.lua/i\sed -i '\''s/\\\"nas\\\"/\\\"services\\\"/g'\'' /usr/lib/lua/luci/controller/hd_idle.lua' package/emortal/default-settings/files/99-default-settings
sed -i '/dispatcher.lua/i\sed -i '\''s/\\\"nas\\\"/\\\"services\\\"/g'\'' /usr/lib/lua/luci/controller/vsftpd.lua' package/emortal/default-settings/files/99-default-settings
sed -i '/dispatcher.lua/i\sed -i '\''s/\\\"NAS\\\"/\\\"Services\\\"/g'\'' /usr/lib/lua/luci/controller/vsftpd.lua' package/emortal/default-settings/files/99-default-settings
sed -i '/dispatcher.lua/i\sed -i '\''s/\\\"nas\\\"/\\\"services\\\"/g'\'' /usr/lib/lua/luci/controller/filebrowser.lua' package/emortal/default-settings/files/99-default-settings
sed -i '/dispatcher.lua/i\sed -i '\''s/\\\"NAS\\\"/\\\"Services\\\"/g'\'' /usr/lib/lua/luci/controller/filebrowser.lua' package/emortal/default-settings/files/99-default-settings
sed -i '/dispatcher.lua/i\sed -i '\''s/nas/services/g'\'' /usr/lib/lua/luci/view/filebrowser/filebrowser_status.htm' package/emortal/default-settings/files/99-default-settings
sed -i '/dispatcher.lua/i\sed -i '\''s/\\\"nas\\\"/\\\"services\\\"/g'\'' /usr/lib/lua/luci/controller/alist.lua' package/emortal/default-settings/files/99-default-settings
sed -i '/dispatcher.lua/i\sed -i '\''s/\\\"NAS\\\"/\\\"Services\\\"/g'\'' /usr/lib/lua/luci/controller/alist.lua' package/emortal/default-settings/files/99-default-settings
sed -i '/dispatcher.lua/i\sed -i '\''s/nas/services/g'\'' /usr/lib/lua/luci/view/alist/admin_info.htm' package/emortal/default-settings/files/99-default-settings
sed -i '/dispatcher.lua/i\sed -i '\''s/nas/services/g'\'' /usr/lib/lua/luci/view/alist/alist_log.htm' package/emortal/default-settings/files/99-default-settings
sed -i '/dispatcher.lua/i\sed -i '\''s/nas/services/g'\'' /usr/lib/lua/luci/view/alist/alist_status.htm' package/emortal/default-settings/files/99-default-settings
sed -i '/dispatcher.lua/i\sed -i '\''s/\\\"nas\\\"/\\\"services\\\"/g'\'' /usr/lib/lua/luci/controller/rclone.lua' package/emortal/default-settings/files/99-default-settings
sed -i '/dispatcher.lua/i\sed -i '\''s/\\\"NAS\\\"/\\\"Services\\\"/g'\'' /usr/lib/lua/luci/controller/rclone.lua' package/emortal/default-settings/files/99-default-settings

# Add alias & bind to profile
sed -i "/alF/a\alias l=\'ls -CF\'" package/base-files/files/etc/profile
sed -i "/alF/a\alias la=\'ls -A\'" package/base-files/files/etc/profile
cat >> package/base-files/files/etc/profile <<EOF

bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'
EOF

# Change banner
cp -f ${WORK_SPACE}/general/etc/immortalwrt_banner package/base-files/files/etc/banner
sed -i '/openwrt_banner/i\echo " -----------------------------------" >> /etc/banner\
echo " [33mOpenwrt-18.06 OPENWRT_VERSION $(uname -r)[0m" >> /etc/banner\
echo >> /etc/banner' package/emortal/default-settings/files/99-default-settings
sed -i "s|OPENWRT_VERSION|$(date +%Y%m%d)|g" package/emortal/default-settings/files/99-default-settings
sed -i '/openwrt_banner/c rm /etc/openwrt_banner' package/emortal/default-settings/files/99-default-settings

# Modify firewall config
sed -i '5s/REJECT/ACCEPT/' package/network/config/firewall/files/firewall.config
sed -i '/exit/i\echo -e "\niptables -t nat -A POSTROUTING -s 172.31.0.0/16 ! -o docker0 -j MASQUERADE" >> /etc/firewall.user\
' package/emortal/default-settings/files/99-default-settings

# Add applications
git clone --single-branch --depth=1 https://github.com/sbwml/luci-app-alist package/luci-app-alist

# Dump golang version
sed -i 's/GO_VERSION_MAJOR_MINOR:=.*/GO_VERSION_MAJOR_MINOR:=1.19/g' feeds/packages/lang/golang/golang/Makefile
sed -i 's/GO_VERSION_PATCH:=.*/GO_VERSION_PATCH:=2/g' feeds/packages/lang/golang/golang/Makefile
sed -i 's/PKG_HASH:=.*/PKG_HASH:=2ce930d70a931de660fdaf271d70192793b1b240272645bf0275779f6704df6b/g' feeds/packages/lang/golang/golang/Makefile

./scripts/feeds update -a
./scripts/feeds install -a
