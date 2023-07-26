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

# Add customize command
sed -i -e "/alF/a\alias l=\'ls -CF\'" -e "/alF/a\alias la=\'ls -A\'" package/base-files/files/etc/profile
sed -i 's/alF/alhF/' package/base-files/files/etc/profile
sed -i 's/alF/alhF/' package/base-files/files/etc/shinit
cat >> package/base-files/files/etc/profile <<EOF

# Change directory aliases
[ -d /mnt/mmcblk2p4 ] && alias 2p4='cd /mnt/mmcblk2p4'
[ -d /mnt/sda1 ] && alias sda1='cd /mnt/sda1'
alias bd='cd "\$OLDPWD"'

# Alias's for archives
alias mktar='tar -cvf'
alias mkbz2='tar -cvjf'
alias mkgz='tar -cvzf'
alias untar='tar -xvf'
alias unbz2='tar -xvjf'
alias ungz='tar -xvzf'

# alias chmod commands
alias mx='chmod +x'
alias 000='chmod -R 000'
alias 644='chmod -R 644'
alias 666='chmod -R 666'
alias 755='chmod -R 755'
alias 777='chmod -R 777'

# Copy and go to the directory
cpg ()
{
    if [ -d "\$2" ];then
        cp \$1 \$2 && cd \$2
    else
        cp \$1 \$2
    fi
}

# Move and go to the directory
mvg ()
{
    if [ -d "\$2" ];then
        mv \$1 \$2 && cd \$2
    else
        mv \$1 \$2
    fi
}

# Create and go to the directory
mkdirg ()
{
    mkdir -p \$1
    cd \$1
}

# History search ↑ ↓
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'
EOF

# Change banner
sed -i '/openwrt_banner/i\echo "" > /etc/banner\
echo "────────────────────────────────" >> /etc/banner\
echo "  ╷┌┬┐┌┬┐┌─┐┌─╶┬╴┌─┐╷ ╷╷╷┌─╶┬╴" >> /etc/banner\
echo "  ╵╵╵╵╵╵╵└─┘╵  ╵ ╵‾╵└─└┴┘╵  ╵ " >> /etc/banner\
echo "────────── 18.06 k5.4 ──────────" >> /etc/banner\
' package/emortal/default-settings/files/99-default-settings
sed -i '/openwrt_banner/c rm /etc/openwrt_banner' package/emortal/default-settings/files/99-default-settings

# Add luci-app-mosdns
# rm -rf feeds/packages/net/v2ray-geodata
# git clone --depth=1 --single-branch -b v5 https://github.com/sbwml/luci-app-mosdns package/mosdns
# git clone https://github.com/sbwml/v2ray-geodata package/v2ray-geodata

# Add luci-app-alist & change menu
# git clone --single-branch --depth=1 https://github.com/sbwml/luci-app-alist package/luci-app-alist
# sed -i -e 's/nas/services/g' -e 's/NAS/Services/g' package/luci-app-alist/luci-app-alist/luasrc/controller/alist.lua
# sed -i 's/nas/services/g' package/luci-app-alist/luci-app-alist/luasrc/view/alist/admin_info.htm
# sed -i 's/nas/services/g' package/luci-app-alist/luci-app-alist/luasrc/view/alist/alist_log.htm
# sed -i 's/nas/services/g' package/luci-app-alist/luci-app-alist/luasrc/view/alist/alist_status.htm

# Dump golonag
# sed -i 's/GO_VERSION_MAJOR_MINOR:=.*/GO_VERSION_MAJOR_MINOR:=1.19/g' feeds/packages/lang/golang/golang/Makefile
# sed -i 's/GO_VERSION_PATCH:=.*/GO_VERSION_PATCH:=6/g' feeds/packages/lang/golang/golang/Makefile
# sed -i 's/PKG_HASH:=.*/PKG_HASH:=d7f0013f82e6d7f862cc6cb5c8cdb48eef5f2e239b35baa97e2f1a7466043767/g' feeds/packages/lang/golang/golang/Makefile
# rm -rf feeds/packages/lang/golang
# cp -rf ${GITHUB_WORKSPACE}/files/golang feeds/packages/lang/golang

./scripts/feeds update -a
./scripts/feeds install -a
