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

# Add customize command
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

# Alias's for archives
alias mktar='tar -cvf'
alias mkbz2='tar -cvjf'
alias mkgz='tar -cvzf'
alias untar='tar -xvf'
alias unbz2='tar -xvjf'
alias ungz='tar -xvzf'

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
cat >> feeds/packages/utils/vim/files/vimrc.full <<EOF

noremap H ^
noremap L \$

set tabstop=4
set shiftwidth=4
set expandtab
set softtabstop=4
set smartindent
set autoindent
set shiftround
set number
set nowrap
set sidescroll=1
set cursorline
set magic
set novisualbell
set noerrorbells
set hlsearch
set mouse=""

filetype plugin indent on
autocmd Filetype yaml set tabstop=2 shiftwidth=2 softtabstop=2

if &term =~ "xterm"
    let &t_SI = "\<Esc>[6 q"
    let &t_SR = "\<Esc>[3 q"
    let &t_EI = "\<Esc>[2 q"
endif

set background=dark
colorscheme desert

function GetMode()
    if mode() == 'v'
        return "SEL"
    elseif mode() == 'V'
        return "SEL"
    elseif mode() == ''
        return "SEL"
    elseif mode() == 'i'
        return "INS"
    else
        return "NOR"
    endif
endfunction
set statusline=[%{GetMode()}]\ %<%f\ %h%m%r%w%=%{&ff}\ %l,%c\ \ %p%%
set laststatus=2
set noshowmode
EOF

./scripts/feeds update -a
./scripts/feeds install -a
