#
# 一些命令缩写和增强
#

# 命令缩写
alias ll='ls -alhF --color=auto'
alias la='ls -A'
alias l='ls -CF'
alias mktar='tar -cvf'
alias mkbz2='tar -cvjf'
alias mkgz='tar -cvzf'
alias untar='tar -xvf'
alias unbz2='tar -xvjf'
alias ungz='tar -xvzf'
alias mx='chmod +x'
alias 000='chmod -R 000'
alias 644='chmod -R 644'
alias 666='chmod -R 666'
alias 755='chmod -R 755'
alias 777='chmod -R 777'

# 自用，依赖 `podman pull ffuqiangg/m3u8-dl`
# alias m3u8-dl='podman run --rm -v "/mnt/sda1:/downloads" ffuqiangg/m3u8-dl'

# 复制并进入目录
cpg ()
{
    if [ -d "$2" ];then
        cp "$1" "$2" && cd "$2"
    else
        cp "$1" "$2"
    fi
}

# 移动并进入目录
mvg ()
{
    if [ -d "$2" ];then
        mv "$1" "$2" && cd "$2"
    else
        mv "$1" "$2"
    fi
}

# 创建并进入目录
mkdirg ()
{
    mkdir -p "$1"
    cd "$1"
}

# 返回 N 级目录
up ()
{
    local d=""
    limit=$1
    for ((i=1 ; i <= limit ; i++))
        do
            d=$d/..
        done
    d=$(echo $d | sed 's/^\///')
    if [ -z "$d" ]; then
        d=..
    fi
    cd $d
}

# 匹配命令历史
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'
