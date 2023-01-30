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

# Add customize command
cat >> package/base-files/files/etc/profile <<EOF

# Alias's for multiple directory listing commands
alias ll='ls -alhF --color=auto'
alias la='ls -A'
alias l='ls -CF'
alias clr='clear'

# Alias's for archives
alias mktar='tar -cvf'
alias mkbz2='tar -cvjf'
alias mkgz='tar -cvzf'
alias untar='tar -xvf'
alias unbz2='tar -xvjf'
alias ungz='tar -xvzf'

# Change directory aliases
[ -d /mnt/mmcblk2p4 ] && alias 2p4='cd /mnt/mmcblk2p4'
[ -d /mnt/sda1 ] && alias sda1='cd /mnt/sda1'
alias bd='cd "\$OLDPWD"'

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

# Histoty search ↑ ↓
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'
EOF

# Change banner
sed -i '/exit/i\echo "" > /etc/banner\
echo "[34mLEDE[0m OPENWRT_VERSION $(uname -r)" >> /etc/banner\
echo "" >> /etc/banner\
' package/lean/default-settings/files/zzz-default-settings
sed -i "s|OPENWRT_VERSION|R$(date +%y.%m.%d)|g" package/lean/default-settings/files/zzz-default-settings

# Modify vim
cp -f ${GITHUB_WORKSPACE}/general/vim/vimrc feeds/packages/utils/vim/files/vimrc.full
cp -f ${GITHUB_WORKSPACE}/general/vim/colors/yowish.vim package/base-files/files/etc/colors.vim
cp -f ${GITHUB_WORKSPACE}/general/vim/autoload/yowish.vim package/base-files/files/etc/autoload.vim
sed -i '/exit/i\mv /etc/colors.vim /usr/share/vim/vim*[0-9]*/colors/yowish.vim\
mv /etc/autoload.vim /usr/share/vim/vim*[0-9]*/autoload/yowish.vim\
' package/lean/default-settings/files/zzz-default-settings

# Add passwall
git clone --single-branch -b luci --depth=1 https://github.com/xiaorouji/openwrt-passwall.git package/luci-app-passwall
git clone --single-branch --depth=1 https://github.com/xiaorouji/openwrt-passwall.git  package/passwall-depends

# Add filebrowser & change menu
svn co https://github.com/Lienol/openwrt-package/trunk/luci-app-filebrowser package/luci-app-filebrowser
sed -i -e 's/nas/services/g' -e 's/NAS/Services/g' package/luci-app-filebrowser/luasrc/controller/filebrowser.lua
sed -i 's/nas/services/g' package/luci-app-filebrowser/luasrc/view/filebrowser/download.htm
sed -i 's/nas/services/g' package/luci-app-filebrowser/luasrc/view/filebrowser/log.htm
sed -i 's/nas/services/g' package/luci-app-filebrowser/luasrc/view/filebrowser/status.htm

# Add luci-app-mosdns
# find ./ | grep Makefile | grep v2ray-geodata | xargs rm -f
# git clone --depth=1 --single-branch https://github.com/sbwml/luci-app-mosdns.git package/luci-app-mosdns
# git clone https://github.com/sbwml/v2ray-geodata package/v2ray-geodata

# Add luci-app-alist & change menu
git clone --single-branch -b master --depth=1 https://github.com/sbwml/luci-app-alist package/luci-app-alist
sed -i -e 's/nas/services/g' -e 's/NAS/Services/g' package/luci-app-alist/luci-app-alist/luasrc/controller/alist.lua
sed -i 's/nas/services/g' package/luci-app-alist/luci-app-alist/luasrc/view/alist/admin_info.htm
sed -i 's/nas/services/g' package/luci-app-alist/luci-app-alist/luasrc/view/alist/alist_log.htm
sed -i 's/nas/services/g' package/luci-app-alist/luci-app-alist/luasrc/view/alist/alist_status.htm

./scripts/feeds update -a
./scripts/feeds install -a
