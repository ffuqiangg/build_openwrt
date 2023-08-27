#!/bin/bash

# Modify default IP (FROM 192.168.1.1 CHANGE TO 192.168.1.99 )
sed -i 's/192.168.1.1/192.168.1.99/g' package/base-files/files/bin/config_generate

# Modify menu
# samba4
sed -i 's/\"nas\"/\"services\"/g' package/feeds/luci/luci-app-samba4/luasrc/controller/samba4.lua
# cpufreq
sed -i 's/\"system\"/\"services\"/g' package/feeds/luci/luci-app-cpufreq/luasrc/controller/cpufreq.lua
# hd-idle
sed -i 's/\"nas\"/\"services\"/g' package/feeds/luci/luci-app-hd-idle/luasrc/controller/hd_idle.lua
# vsftpd
sed -i -e 's/\"nas\"/\"services\"/g' -e 's/NAS/Services/g' package/feeds/luci/luci-app-vsftpd/luasrc/controller/vsftpd.lua
# filebrowser
sed -i -e 's/\"nas\"/\"services\"/g' -e 's/NAS/Services/g' package/feeds/luci/luci-app-filebrowser/luasrc/controller/filebrowser.lua
sed -i 's/nas/services/g' package/feeds/luci/luci-app-filebrowser/luasrc/view/filebrowser/filebrowser_status.htm
# rclone
sed -i -e 's/\"nas\"/\"services\"/g' -e 's/NAS/Services/g' package/feeds/luci/luci-app-rclone/luasrc/controller/rclone.lua
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
sed -i '/exit/i\echo "╭────────────────────────────────╮" > /etc/banner\
echo "│[36m  ╷┌┬┐┌┬┐┌─┐┌─╶┬╴┌─┐╷ ╷╷╷┌─╶┬╴  [0m│" >> /etc/banner\
echo "│[36m  ╵╵╵╵╵╵╵└─┘╵  ╵ ╵‾╵└─└┴┘╵  ╵   [0m│" >> /etc/banner\
echo "╰────────────────────────────────╯" >> /etc/banner\
' package/emortal/default-settings/files/99-default-settings
sed -i '/openwrt_banner/c rm /etc/openwrt_banner' package/emortal/default-settings/files/99-default-settings

# Add luci-app-mosdns
rm -rf feeds/packages/net/v2ray-geodata
git clone --depth=1 --single-branch -b v5 https://github.com/sbwml/luci-app-mosdns package/mosdns
git clone https://github.com/sbwml/v2ray-geodata package/v2ray-geodata
