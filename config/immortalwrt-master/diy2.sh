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

# Add the default password for the 'root' user（Change the empty password to 'password'）
sed -i 's/root:::0:99999:7:::/root:$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.::0:99999:7:::/g' package/base-files/files/etc/shadow

# Modify default IP (FROM 192.168.1.1 CHANGE TO 192.168.1.99 )
sed -i 's/192.168.1.1/192.168.1.99/g' package/base-files/files/bin/config_generate

# Modify menu
# samba4
sed -i 's/nas/services/g' package/feeds/luci/luci-app-samba4/root/usr/share/luci/menu.d/luci-app-samba4.json
# cpufreq
sed -i 's/system/services/g' package/feeds/luci/luci-app-cpufreq/root/usr/share/luci/menu.d/luci-app-cpufreq.json
# hd-idle
sed -i 's/nas/services/g' package/feeds/luci/luci-app-hd-idle/root/usr/share/luci/menu.d/luci-app-hd-idle.json
# vsftpd
sed -i -e 's/\"nas\"/\"services\"/g' -e 's/NAS/Services/g' package/feeds/luci/luci-app-vsftpd/luasrc/controller/vsftpd.lua
sed -i 's/nas/services/g' package/feeds/luci/luci-app-vsftpd/luasrc/model/cbi/vsftpd/item.lua
sed -i 's/nas/services/g' package/feeds/luci/luci-app-vsftpd/luasrc/model/cbi/vsftpd/users.lua
# filebrowser
# sed -i -e 's/\"nas\"/\"services\"/g' -e 's/NAS/Services/g' package/feeds/luci/luci-app-filebrowser/luasrc/controller/filebrowser.lua
# sed -i 's/nas/services/g' package/feeds/luci/luci-app-filebrowser/luasrc/view/filebrowser/filebrowser_status.htm
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
sed -i 's/services/network/g' package/feeds/luci/luci-app-nlbwmon/root/usr/share/luci/menu.d/luci-app-nlbwmon.json

# Add customize command
sed -i 's/alF/alhF/' package/base-files/files/etc/profile
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
sed -i '/exit/i\echo "" > /etc/banner\
echo "[34mImmortalwrt[0m" >> /etc/banner\
echo "[34m───────────[0m" >> /etc/banner\
echo "kernel: $(uname -r)" >> /etc/banner\
' package/emortal/default-settings/files/99-default-settings

# Modify vim
cp -f ${GITHUB_WORKSPACE}/files/vim/.vimrc package/base-files/files/etc/
sed -i '/exit/i\mv /etc/.vimrc /root/\
' package/emortal/default-settings/files/99-default-settings

# Change 30-sysinfo.sh in ophub/amlogic-s9xxx-openwrt
sed -i '/exit/i\mv /etc/profile.d/30-sysinfo.sh.bak /etc/profile.d/30-sysinfo.sh\
' package/emortal/default-settings/files/99-default-settings

# Modify rootfs size on emmc
sed -i "/exit/i\sed -i -e \'\/ROOT1=\/c ROOT1=\\\\\"720\\\\\"\' -e \'\/ROOT2=\/c ROOT2=\\\\\"720\\\\\"\' \/usr\/sbin\/openwrt-install-amlogic\
" package/emortal/default-settings/files/99-default-settings

# Add luci-app-amlogic
svn co https://github.com/ophub/luci-app-amlogic/trunk/luci-app-amlogic package/luci-app-amlogic

# Add luci-app-mosdns
rm -rf feeds/packages/net/v2ray-geodata
git clone --single-branch --depth=1 https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns
git clone https://github.com/sbwml/v2ray-geodata package/v2ray-geodata

# ./scripts/feeds update -a
# ./scripts/feeds install -a
