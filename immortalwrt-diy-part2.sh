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

# Change PS1
sed -i "/^export PS1/c export PS1='[\\\u]\\\w ➜ '" package/base-files/files/etc/profile

# Add customize command
sed -i -e "/alF/a\alias l=\'ls -CF\'" -e "/alF/a\alias la=\'ls -A\'" package/base-files/files/etc/profile
sed -i 's/alF/alhF/' package/base-files/files/etc/profile
cat >> package/base-files/files/etc/profile <<EOF

# Change directory aliases
alias home='cd ~'
alias cd..='cd ..'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
[ -d /mnt/mmcblk2p4 ] && alias 2p4='cd /mnt/mmcblk2p4'
[ -d /mnt/sda1 ] && alias sda1='cd /mnt/sda1'

# cd into the old directory
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

# Modify vimrc
cp -f ${GITHUB_WORKSPACE}/general/vim/molokai.vim package/base-files/files/etc/
sed -i '/exit/i\mv /etc/molokai.vim /usr/share/vim/vim??/colors/\n' package/emortal/default-settings/files/99-default-settings
sed -i '1i colorscheme molokai\n' feeds/packages/utils/vim/files/vimrc.full
cat >> feeds/packages/utils/vim/files/vimrc.full <<EOF
set tabstop=4
set shiftwidth=4
set expandtab
set softtabstop=4
set number
set cursorline
set nowrap
set sidescroll=1

" Auto ([{
inoremap ( ()<Esc>i
inoremap [ []<Esc>i
inoremap < <><Esc>i
inoremap { {}<Esc>i
inoremap ' ''<Esc>i
inoremap " ""<Esc>i
EOF

# Change banner
cp -f ${GITHUB_WORKSPACE}/general/etc/immortalwrt.banner package/base-files/files/etc/banner
sed -i '/openwrt_banner/i\echo " -------------------------------------------" >> /etc/banner\
echo " [33mImmortalwrt-18.06-OPENWRT_VERSION $(uname -r)[0m" >> /etc/banner\
echo >> /etc/banner' package/emortal/default-settings/files/99-default-settings
sed -i "s|OPENWRT_VERSION|$(date +%Y%m%d)|g" package/emortal/default-settings/files/99-default-settings
sed -i '/openwrt_banner/c rm /etc/openwrt_banner' package/emortal/default-settings/files/99-default-settings

# Modify firewall config for docker
sed -i '5s/REJECT/ACCEPT/' package/network/config/firewall/files/firewall.config
sed -i '/exit/i\echo -e "\\niptables -t nat -A POSTROUTING -s 172.31.0.0/16 ! -o docker0 -j MASQUERADE" >> /etc/firewall.user\
' package/emortal/default-settings/files/99-default-settings

# Add applications
git clone --single-branch --depth=1 https://github.com/sbwml/luci-app-alist package/luci-app-alist

# Dump golang version
sed -i 's/GO_VERSION_MAJOR_MINOR:=.*/GO_VERSION_MAJOR_MINOR:=1.19/g' feeds/packages/lang/golang/golang/Makefile
sed -i 's/GO_VERSION_PATCH:=.*/GO_VERSION_PATCH:=2/g' feeds/packages/lang/golang/golang/Makefile
sed -i 's/PKG_HASH:=.*/PKG_HASH:=2ce930d70a931de660fdaf271d70192793b1b240272645bf0275779f6704df6b/g' feeds/packages/lang/golang/golang/Makefile

./scripts/feeds update -a
./scripts/feeds install -a
