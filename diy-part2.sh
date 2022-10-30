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
sed -i "s|DISTRIB_REVISION='.*'|DISTRIB_REVISION='R$(date +%y.%m.%d)'|g" package/lean/default-settings/files/zzz-default-settings

# Modify menu
startLine=$(cat package/lean/default-settings/files/zzz-default-settings | grep -n services | head -1 | cut -d : -f 1)
sed -i '/services/d' package/lean/default-settings/files/zzz-default-settings
sed -i "${startLine}i\sed -i 's/\\\\\"nas\\\\\"/\\\\\"services\\\\\"/g' /usr/lib/lua/luci/controller/vsftpd.lua" package/lean/default-settings/files/zzz-default-settings
sed -i "${startLine}i\sed -i 's/\\\\\"NAS\\\\\"/\\\\\"Services\\\\\"/g' /usr/lib/lua/luci/controller/vsftpd.lua" package/lean/default-settings/files/zzz-default-settings
sed -i "${startLine}i\sed -i 's/\\\\\"system\\\\\"/\\\\\"services\\\\\"/g' /usr/lib/lua/luci/controller/cpufreq.lua" package/lean/default-settings/files/zzz-default-settings
sed -i "${startLine}i\sed -i 's/\\\\\"nas\\\\\"/\\\\\"services\\\\\"/g' /usr/lib/lua/luci/controller/filebrowser.lua" package/lean/default-settings/files/zzz-default-settings
sed -i "${startLine}i\sed -i 's/\\\\\"NAS\\\\\"/\\\\\"Services\\\\\"/g' /usr/lib/lua/luci/controller/filebrowser.lua" package/lean/default-settings/files/zzz-default-settings
sed -i "${startLine}i\sed -i 's/nas/services/g' /usr/lib/lua/luci/view/filebrowser/status.htm" package/lean/default-settings/files/zzz-default-settings
sed -i "${startLine}i\sed -i 's/nas/services/g' /usr/lib/lua/luci/view/filebrowser/log.htm" package/lean/default-settings/files/zzz-default-settings
sed -i "${startLine}i\sed -i 's/nas/services/g' /usr/lib/lua/luci/view/filebrowser/download.htm" package/lean/default-settings/files/zzz-default-settings
sed -i "${startLine}i\sed -i 's/\\\\\"nas\\\\\"/\\\\\"services\\\\\"/g' /usr/lib/lua/luci/controller/alist.lua" package/lean/default-settings/files/zzz-default-settings
sed -i "${startLine}i\sed -i 's/\\\\\"NAS\\\\\"/\\\\\"Services\\\\\"/g' /usr/lib/lua/luci/controller/alist.lua" package/lean/default-settings/files/zzz-default-settings
sed -i "${startLine}i\sed -i 's/nas/services/g' /usr/lib/lua/luci/view/alist/admin_info.htm" package/lean/default-settings/files/zzz-default-settings
sed -i "${startLine}i\sed -i 's/nas/services/g' /usr/lib/lua/luci/view/alist/alist_log.htm" package/lean/default-settings/files/zzz-default-settings
sed -i "${startLine}i\sed -i 's/nas/services/g' /usr/lib/lua/luci/view/alist/alist_status.htm" package/lean/default-settings/files/zzz-default-settings
sed -i "${startLine}i\sed -i 's/\\\\\"nas\\\\\"/\\\\\"services\\\\\"/g' /usr/lib/lua/luci/controller/rclone.lua" package/lean/default-settings/files/zzz-default-settings
sed -i "${startLine}i\sed -i 's/\\\\\"NAS\\\\\"/\\\\\"Services\\\\\"/g' /usr/lib/lua/luci/controller/rclone.lua" package/lean/default-settings/files/zzz-default-settings

# Add alias & bind to profile
cat >> package/base-files/files/etc/profile <<EOF

alias ll='ls -alF --color=auto'
alias la='ls -A'
alias l='ls -CF'

bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'
EOF

# Change banner
cp -f ${GITHUB_WORKSPACE}/general/etc/banner package/base-files/files/etc/banner
sed -i '/exit/i\echo " -----------------------------------" >> /etc/banner\
echo " [33mLEDE OPENWRT_VERSION $(uname -r)[0m" >> /etc/banner\
echo >> /etc/banner\
' package/lean/default-settings/files/zzz-default-settings
sed -i "s|OPENWRT_VERSION|R$(date +%y.%m.%d)|g" package/lean/default-settings/files/zzz-default-settings

# Add applications
git clone --single-branch -b luci --depth=1 https://github.com/xiaorouji/openwrt-passwall.git package/luci-app-passwall
git clone --single-branch --depth=1 https://github.com/xiaorouji/openwrt-passwall.git  package/passwall-depends
svn co https://github.com/Lienol/openwrt-package/trunk/luci-app-filebrowser package/luci-app-filebrowser
git clone --single-branch --depth=1 https://github.com/sbwml/luci-app-alist package/luci-app-alist

# Dump golang version
sed -i 's/GO_VERSION_MAJOR_MINOR:=.*/GO_VERSION_MAJOR_MINOR:=1.19/g' feeds/packages/lang/golang/golang/Makefile
sed -i 's/GO_VERSION_PATCH:=.*/GO_VERSION_PATCH:=2/g' feeds/packages/lang/golang/golang/Makefile
sed -i 's/PKG_HASH:=.*/PKG_HASH:=2ce930d70a931de660fdaf271d70192793b1b240272645bf0275779f6704df6b/g' feeds/packages/lang/golang/golang/Makefile

./scripts/feeds update -a
./scripts/feeds install -a
