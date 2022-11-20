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

# Add customize command
cat >> package/base-files/files/etc/profile <<EOF

# Alias's for multiple directory listing commands
alias ll='ls -alhF --color=auto'
alias la='ls -A'
alias l='ls -CF'
alias clr='clear'

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

# Change banner
cp -f ${GITHUB_WORKSPACE}/general/etc/banner package/base-files/files/etc/banner
sed -i '/exit/i\echo " -----------------------------------" >> /etc/banner\
echo " [33mLEDE OPENWRT_VERSION $(uname -r)[0m" >> /etc/banner\
echo >> /etc/banner\
' package/lean/default-settings/files/zzz-default-settings
sed -i "s|OPENWRT_VERSION|R$(date +%y.%m.%d)|g" package/lean/default-settings/files/zzz-default-settings

# Modify vimrc
cp -f ${GITHUB_WORKSPACE}/general/vim/molokai.vim package/base-files/files/etc/
sed -i '/exit/i\mv /etc/molokai.vim /usr/share/vim/vim??/colors/\n' package/lean/default-settings/files/zzz-default-settings
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

# Modify firewall config for docker
sed -i '5s/REJECT/ACCEPT/' package/network/config/firewall/files/firewall.config
sed -i '/exit/i\echo -e "\\niptables -t nat -A POSTROUTING -s 172.31.0.0/16 ! -o docker0 -j MASQUERADE" >> /etc/firewall.user\
' package/lean/default-settings/files/zzz-default-settings

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
