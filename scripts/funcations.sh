#!/bin/bash

openwrt_repo="https://github.com/openwrt/openwrt.git"
openwrt_pkg_repo="https://github.com/openwrt/packages.git"
immortalwrt_repo="https://github.com/immortalwrt/immortalwrt.git"
immortalwrt_pkg_repo="https://github.com/immortalwrt/packages.git"
immortalwrt_luci_repo="https://github.com/immortalwrt/luci.git"
lede_repo="https://github.com/coolsnowwolf/lede.git"
lede_luci_repo="https://github.com/coolsnowwolf/luci.git"
lede_pkg_repo="https://github.com/coolsnowwolf/packages.git"
lienol_repo="https://github.com/Lienol/openwrt.git"
lienol_pkg_repo="https://github.com/Lienol/openwrt-package"
openwrt_add_repo="https://github.com/QiuSimons/OpenWrt-Add.git"
passwall_pkg_repo="https://github.com/xiaorouji/openwrt-passwall-packages"
passwall_luci_repo="https://github.com/xiaorouji/openwrt-passwall"
dockerman_repo="https://github.com/lisaac/luci-app-dockerman"
diskman_repo="https://github.com/lisaac/luci-app-diskman"
docker_lib_repo="https://github.com/lisaac/luci-lib-docker"
mosdns_repo="https://github.com/QiuSimons/openwrt-mos"
sirpdboy_repo="https://github.com/sirpdboy/sirpdboy-package"

clone_repo() {
    repo_url=$1
    branch_name=$2
    target_dir=$3
    git clone -b $branch_name --depth 1 $repo_url $target_dir
}

move_2_services() {
    local lua_file="$({ find |grep "\.lua"; } 2>"/dev/null")"
    for a in ${lua_file}
    do
        [ -n "$(grep "\"$1\"" "$a")" ] && sed -i "s,\"$1\",\"services\",g" "$a"
        [ -n "$(grep "\"${1^^}\"" "$a")" ] && sed -i "s,\"${1^^}\",\"Services\",g" "$a"
        [ -n "$(grep "\"${1^}\"" "$a")" ] && sed -i "s,\"${1^}\",\"Services\",g" "$a"
        [ -n "$(grep "\[\[$1\]\]" "$a")" ] && sed -i "s,\[\[$1\]\],\[\[services\]\],g" "$a"
        [ -n "$(grep "admin/$1" "$a")" ] && sed -i "s,admin/$1,admin/services,g" "$a"
    done

    local htm_file="$({ find |grep "\.htm"; } 2>"/dev/null")"
    for b in ${htm_file}
    do
        [ -n "$(grep "\"$1\"" "$b")" ] && sed -i "s,\"$1\",\"services\",g" "$b"
        [ -n "$(grep "\"${1^^}\"" "$b")" ] && sed -i "s,\"${1^^}\",\"Services\",g" "$b"
        [ -n "$(grep "\"${1^}\"" "$b")" ] && sed -i "s,\"${1^}\",\"Services\",g" "$b"
        [ -n "$(grep "\[\[$1\]\]" "$b")" ] && sed -i "s,\[\[$1\]\],\[\[services\]\],g" "$b"
        [ -n "$(grep "admin/$1" "$b")" ] && sed -i "s,admin/$1,admin/services,g" "$b"
    done

    local json_file="$({ find |grep "\.json"; } 2>"/dev/null")"
    for c in ${json_file}
    do
        [ -n "$(grep "\"$1\"" "$c")" ] && sed -i "s,\"$1\",\"services\",g" "$c"
        [ -n "$(grep "\"${1^^}\"" "$c")" ] && sed -i "s,\"${1^^}\",\"Services\",g" "$c"
        [ -n "$(grep "\"${1^}\"" "$c")" ] && sed -i "s,\"${1^}\",\"Services\",g" "$c"
        [ -n "$(grep "\[\[$1\]\]" "$c")" ] && sed -i "s,\[\[$1\]\],\[\[services\]\],g" "$c"
        [ -n "$(grep "admin/$1" "$c")" ] && sed -i "s,admin/$1,admin/services,g" "$c"
    done
}

docker_2_services() {
    local lua_file="$({ find |grep "\.lua"; } 2>"/dev/null")"
    for a in ${lua_file}
    do
        [ -n "$(grep 'admin\",' "$a")" ] && sed -i "s|admin\",|& \"services\",|g" "$a"
        [ -n "$(grep 'Docker' "$a")" ] && sed -i "s,Docker,&Man,g" "$a"
        [ -n "$(grep 'config\")' "$a")" ] && sed -i "s,config\"),overview\"),g" "$a"
        [ -n "$(grep 'admin/' "$a")" ] && sed -i "s,admin/,&services/,g" "$a"
        [ -n "$(grep 'admin\\/' "$a")" ] && sed -i "s,admin\\/,&services\\/,g" "$a"
    done

    local htm_file="$({ find |grep "\.htm"; } 2>"/dev/null")"
    for b in ${htm_file}
    do
        [ -n "$(grep 'admin\",' "$a")" ] && sed -i "s|admin\",|& \"services\",|g" "$a"
        [ -n "$(grep 'Docker' "$a")" ] && sed -i "s,Docker,&Man,g" "$a"
        [ -n "$(grep 'config\")' "$a")" ] && sed -i "s,config\"),overview\"),g" "$a"
        [ -n "$(grep 'admin/' "$a")" ] && sed -i "s,admin/,&services/,g" "$a"
        [ -n "$(grep 'admin\\/' "$a")" ] && sed -i "s,admin\\/,&services\\/,g" "$a"
    done
}