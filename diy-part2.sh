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
sed -i "${startLine}i\sed -i 's/\\\\\"nas\\\\\"/\\\\\"services\\\\\"/g' /usr/lib/lua/luci/filebrowser/filebrowser.lua" package/lean/default-settings/files/zzz-default-settings
sed -i "${startLine}i\sed -i 's/\\\\\"NAS\\\\\"/\\\\\"Services\\\\\"/g' /usr/lib/lua/luci/filebrowser/filebrowser.lua" package/lean/default-settings/files/zzz-default-settings
sed -i "${startLine}i\sed -i 's/nas/services/g' /usr/lib/lua/luci/view/filebrowser/filebrowser_status.htm" package/lean/default-settings/files/zzz-default-settings
sed -i "${startLine}i\sed -i 's/\\\\\"nas\\\\\"/\\\\\"services\\\\\"/g' /usr/lib/lua/luci/controller/alist.lua" package/lean/default-settings/files/zzz-default-settings
sed -i "${startLine}i\sed -i 's/\\\\\"NAS\\\\\"/\\\\\"Services\\\\\"/g' /usr/lib/lua/luci/controller/alist.lua" package/lean/default-settings/files/zzz-default-settings
sed -i "${startLine}i\sed -i 's/nas/services/g' /usr/lib/lua/luci/view/alist/admin_info.htm" package/lean/default-settings/files/zzz-default-settings
sed -i "${startLine}i\sed -i 's/nas/services/g' /usr/lib/lua/luci/view/alist/alist_log.htm" package/lean/default-settings/files/zzz-default-settings
sed -i "${startLine}i\sed -i 's/nas/services/g' /usr/lib/lua/luci/view/alist/alist_status.htm" package/lean/default-settings/files/zzz-default-settings
sed -i "${startLine}i\sed -i 's/\\\\\"nas\\\\\"/\\\\\"services\\\\\"/g' /usr/lib/lua/luci/controller/rclone.lua" package/lean/default-settings/files/zzz-default-settings
sed -i "${startLine}i\sed -i 's/\\\\\"NAS\\\\\"/\\\\\"Services\\\\\"/g' /usr/lib/lua/luci/controller/rclone.lua" package/lean/default-settings/files/zzz-default-settings

# Add applications
svn co https://github.com/xiaorouji/openwrt-passwall/branches/luci/luci-app-passwall package/luci-app-passwall
git clone https://github.com/xiaorouji/openwrt-passwall.git --depth=1 package/passwall-depends
svn co https://github.com/Lienol/openwrt-package/trunk/luci-app-filebrowser package/luci-app-filebrowser
git clone --single-branch --depth=1 https://github.com/sbwml/luci-app-alist package/alist

./scripts/feeds update -a
./scripts/feeds install -a
