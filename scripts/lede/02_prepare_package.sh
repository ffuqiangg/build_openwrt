#!/bin/bash

./scripts/feeds update -a
./scripts/feeds install -a

### Prepare package
# Passwall
cp -rf ../passwall_luci ./package/new/luci-app-passwall
cp -rf ../passwall_pkg ./package/new/passwall-pkg
# Openclash
cp -rf ../openclash ./package/new/luci-app-openclash
# Filebrowser
cp -rf ../immortalwrt_luci_18.06_k5.4/applications/luci-app-filebrowser ./package/new/luci-app-filebrowser
# Mosdns
cp -rf ../mosdns/mosdns ./package/new/mosdns
cp -rf ../mosdns/luci-app-mosdns ./package/new/luci-app-mosdns
rm -rf ./feeds/packages/net/v2ray-geodata
cp -rf ../mosdns/v2ray-geodata ./package/new/v2ray-geodata

### Change menu
# Delete default setting
sed -i '/services/d' package/lean/default-settings/files/zzz-default-settings
# vsftpd
sed -i -e 's,\"nas\",\"services\",g' -e 's,\"NAS\",\"Services\",g' package/feeds/luci/luci-app-vsftpd/luasrc/controller/vsftpd.lua
sed -i 's,nas,services,g' package/feeds/luci/luci-app-vsftpd/luasrc/model/cbi/vsftpd/item.lua
sed -i 's,nas,services,g' package/feeds/luci/luci-app-vsftpd/luasrc/model/cbi/vsftpd/users.lua
# cpufreq
sed -i 's,\"system\",\"services\",g' package/feeds/luci/luci-app-cpufreq/luasrc/controller/cpufreq.lua
# rclone
sed -i -e 's,\"NAS\",\"Services\",g' -e 's,\"nas\",\"services\",g' package/feeds/luci/luci-app-rclone/luasrc/controller/rclone.lua
# dockerman
sed -i -e 's|admin\",|& \"services\",|g' -e 's,Docker,&Man,' -e 's,config\"),overview\"),' package/feeds/luci/luci-app-dockerman/luasrc/controller/dockerman.lua
sed -i 's,admin/,&services/,g' package/feeds/luci/luci-app-dockerman/luasrc/model/cbi/dockerman/container.lua
sed -i 's,admin/,&services/,g' package/feeds/luci/luci-app-dockerman/luasrc/model/cbi/dockerman/containers.lua
sed -i 's,admin/,&services/,g' package/feeds/luci/luci-app-dockerman/luasrc/model/cbi/dockerman/images.lua
sed -i 's,admin/,&services/,g' package/feeds/luci/luci-app-dockerman/luasrc/model/cbi/dockerman/networks.lua
sed -i -e 's,admin/,&services/,g' -e 's|admin\",|& \"services\",|g' package/feeds/luci/luci-app-dockerman/luasrc/model/cbi/dockerman/newcontainer.lua
sed -i -e 's,admin/,&services/,g' -e 's|admin\",|& \"services\",|g' package/feeds/luci/luci-app-dockerman/luasrc/model/cbi/dockerman/newnetwork.lua
sed -i 's,admin/,&services/,g' package/feeds/luci/luci-app-dockerman/luasrc/model/cbi/dockerman/overview.lua
sed -i 's,admin/,&services/,g' package/feeds/luci/luci-app-dockerman/luasrc/model/cbi/dockerman/volumes.lua
sed -i 's,admin/,&services/,g' package/feeds/luci/luci-app-dockerman/luasrc/view/dockerman/apply_widget.htm
sed -i -e 's,admin/,&services/,g' -e 's,admin\\/,&services\\/,g' package/feeds/luci/luci-app-dockerman/luasrc/view/dockerman/container.htm
sed -i 's,admin/,&services/,g' package/feeds/luci/luci-app-dockerman/luasrc/view/dockerman/container_file_manager.htm
sed -i 's,admin/,&services/,g' package/feeds/luci/luci-app-dockerman/luasrc/view/dockerman/container_stats.htm
sed -i 's,admin/,&services/,g' package/feeds/luci/luci-app-dockerman/luasrc/view/dockerman/containers_running_stats.htm
sed -i 's,admin/,&services/,g' package/feeds/luci/luci-app-dockerman/luasrc/view/dockerman/images_import.htm
sed -i 's,admin/,&services/,g' package/feeds/luci/luci-app-dockerman/luasrc/view/dockerman/images_load.htm
sed -i 's,admin/,&services/,g' package/feeds/luci/luci-app-dockerman/luasrc/view/dockerman/newcontainer_resolve.htm
sed -i 's,admin/,&services/,g' package/feeds/luci/luci-app-dockerman/luasrc/view/dockerman/overview.htm
sed -i 's,admin/,&services/,g' package/feeds/luci/luci-app-dockerman/luasrc/view/dockerman/volume_size.htm
# nlbw
sed -i -e 's|admin\",|& \"network\",|g' -e 's,admin/,&network/,g' package/feeds/luci/luci-app-nlbwmon/luasrc/controller/nlbw.lua
sed -i 's,admin/,&network/,g' package/feeds/luci/luci-app-nlbwmon/luasrc/model/cbi/nlbw/config.lua
sed -i 's,admin/,&network/,g' package/feeds/luci/luci-app-nlbwmon/luasrc/view/nlbw/backup.htm
sed -i 's,admin/,&network/,g' package/feeds/luci/luci-app-nlbwmon/luasrc/view/nlbw/display.htm
# filebrowser
sed -i -e 's/nas/services/g' -e 's/NAS/Services/g' package/luci-app-filebrowser/luasrc/controller/filebrowser.lua
sed -i 's/nas/services/g' package/luci-app-filebrowser/luasrc/view/filebrowser/filebrowser_status.htm

exit 0
