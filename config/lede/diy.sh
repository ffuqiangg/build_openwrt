#!/bin/bash

# Modify default IP (FROM 192.168.1.1 CHANGE TO 192.168.1.99 )
sed -i 's/192.168.1.1/192.168.1.99/g' package/base-files/files/bin/config_generate

# Set DISTRIB_REVISION
sed -i "s|DISTRIB_REVISION='.*'|DISTRIB_REVISION='R$(date +%y.%m.%d)'|g" package/lean/default-settings/files/zzz-default-settings

# Modify menu
sed -i '/services/d' package/lean/default-settings/files/zzz-default-settings
# vsftpd
sed -i -e 's/\"nas\"/\"services\"/g' -e 's/\"NAS\"/\"Services\"/g' package/feeds/luci/luci-app-vsftpd/luasrc/controller/vsftpd.lua
sed -i 's/nas/services/g' package/feeds/luci/luci-app-vsftpd/luasrc/model/cbi/vsftpd/item.lua
sed -i 's/nas/services/g' package/feeds/luci/luci-app-vsftpd/luasrc/model/cbi/vsftpd/users.lua
# cpufreq
sed -i 's/\"system\"/\"services\"/g' package/feeds/luci/luci-app-cpufreq/luasrc/controller/cpufreq.lua
# rclone
sed -i -e 's/\"NAS\"/\"Services\"/g' -e 's/\"nas\"/\"services\"/g' package/feeds/luci/luci-app-rclone/luasrc/controller/rclone.lua
# dockerman
sed -i -e 's/admin\",/& \"services\",/g' -e 's/Docker/&Man/' -e 's/config\")/overview\")/' package/feeds/luci/luci-app-dockerman/luasrc/controller/dockerman.lua
sed -i 's/admin\//&services\//g' package/feeds/luci/luci-app-dockerman/luasrc/model/cbi/dockerman/container.lua
sed -i 's/admin\//&services\//g' package/feeds/luci/luci-app-dockerman/luasrc/model/cbi/dockerman/containers.lua
sed -i 's/admin\//&services\//g' package/feeds/luci/luci-app-dockerman/luasrc/model/cbi/dockerman/images.lua
sed -i 's/admin\//&services\//g' package/feeds/luci/luci-app-dockerman/luasrc/model/cbi/dockerman/networks.lua
sed -i -e 's/admin\//&services\//g' -e 's/admin\",/& \"services\",/g' package/feeds/luci/luci-app-dockerman/luasrc/model/cbi/dockerman/newcontainer.lua
sed -i -e 's/admin\//&services\//g' -e 's/admin\",/& \"services\",/g' package/feeds/luci/luci-app-dockerman/luasrc/model/cbi/dockerman/newnetwork.lua
sed -i 's/admin\//&services\//g' package/feeds/luci/luci-app-dockerman/luasrc/model/cbi/dockerman/overview.lua
sed -i 's/admin\//&services\//g' package/feeds/luci/luci-app-dockerman/luasrc/model/cbi/dockerman/volumes.lua
sed -i 's/admin\//&services\//g' package/feeds/luci/luci-app-dockerman/luasrc/view/dockerman/apply_widget.htm
sed -i -e 's/admin\//&services\//g' -e 's/admin\\\//&services\\\//g' package/feeds/luci/luci-app-dockerman/luasrc/view/dockerman/container.htm
sed -i 's/admin\//&services\//g' package/feeds/luci/luci-app-dockerman/luasrc/view/dockerman/container_file_manager.htm
sed -i 's/admin\//&services\//g' package/feeds/luci/luci-app-dockerman/luasrc/view/dockerman/container_stats.htm
sed -i 's/admin\//&services\//g' package/feeds/luci/luci-app-dockerman/luasrc/view/dockerman/containers_running_stats.htm
sed -i 's/admin\//&services\//g' package/feeds/luci/luci-app-dockerman/luasrc/view/dockerman/images_import.htm
sed -i 's/admin\//&services\//g' package/feeds/luci/luci-app-dockerman/luasrc/view/dockerman/images_load.htm
sed -i 's/admin\//&services\//g' package/feeds/luci/luci-app-dockerman/luasrc/view/dockerman/newcontainer_resolve.htm
sed -i 's/admin\//&services\//g' package/feeds/luci/luci-app-dockerman/luasrc/view/dockerman/overview.htm
sed -i 's/admin\//&services\//g' package/feeds/luci/luci-app-dockerman/luasrc/view/dockerman/volume_size.htm
# nlbw
sed -i -e 's/admin\",/& \"network\",/g' -e 's/admin\//&network\//g' package/feeds/luci/luci-app-nlbwmon/luasrc/controller/nlbw.lua
sed -i 's/admin\//&network\//g' package/feeds/luci/luci-app-nlbwmon/luasrc/model/cbi/nlbw/config.lua
sed -i 's/admin\//&network\//g' package/feeds/luci/luci-app-nlbwmon/luasrc/view/nlbw/backup.htm
sed -i 's/admin\//&network\//g' package/feeds/luci/luci-app-nlbwmon/luasrc/view/nlbw/display.htm

# Change banner
sed -i '/exit/i echo "" > /etc/banner\
echo "╷  ┌─┐  _╷ ┌─┐" >> /etc/banner\
echo "└─ └─  └─┘ └─" >> /etc/banner\
echo "──────────────" >> /etc/banner\
echo "build by ffuqiangg @ BUILD_DATE" >> /etc/banner\
echo "" >> /etc/banner\
' package/lean/default-settings/files/zzz-default-settings
sed -i "s/BUILD_DATE/$(date +%Y.%m.%d)/" package/lean/default-settings/files/zzz-default-settings

# Add passwall
# git clone --single-branch -b luci --depth=1 https://github.com/xiaorouji/openwrt-passwall.git package/luci-app-passwall
# passwall2
git clone --single-branch --depth=1 https://github.com/xiaorouji/openwrt-passwall2 package/luci-app-passwall2
# depends
git clone --single-branch --depth=1 https://github.com/xiaorouji/openwrt-passwall.git  package/passwall-depends


# Add filebrowser & change menu
svn co https://github.com/Lienol/openwrt-package/trunk/luci-app-filebrowser package/luci-app-filebrowser
sed -i -e 's/nas/services/g' -e 's/NAS/Services/g' package/luci-app-filebrowser/luasrc/controller/filebrowser.lua
sed -i 's/nas/services/g' package/luci-app-filebrowser/luasrc/view/filebrowser/download.htm
sed -i 's/nas/services/g' package/luci-app-filebrowser/luasrc/view/filebrowser/log.htm
sed -i 's/nas/services/g' package/luci-app-filebrowser/luasrc/view/filebrowser/status.htm

# Add luci-app-openclash
svn co https://github.com/vernesong/OpenClash/trunk/luci-app-openclash package/luci-app-openclash

# Add luci-app-mosdns
find ./ | grep Makefile | grep v2ray-geodata | xargs rm -f
find ./ | grep Makefile | grep mosdns | xargs rm -f
git clone --depth=1 --single-branch -b v5 https://github.com/sbwml/luci-app-mosdns package/mosdns
git clone https://github.com/sbwml/v2ray-geodata package/v2ray-geodata
