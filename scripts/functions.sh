#!/bin/bash

openwrt_repo="https://github.com/openwrt/openwrt.git"
openwrt_pkg_repo="https://github.com/openwrt/packages.git"
openwrt_luci_repo="https://github.com/openwrt/luci.git"
immortalwrt_repo="https://github.com/immortalwrt/immortalwrt.git"
immortalwrt_pkg_repo="https://github.com/immortalwrt/packages.git"
immortalwrt_luci_repo="https://github.com/immortalwrt/luci.git"
lede_repo="https://github.com/coolsnowwolf/lede.git"
lede_pkg_repo="https://github.com/coolsnowwolf/packages.git"
lede_luci_repo="https://github.com/coolsnowwolf/luci.git"
istoreos_repo="https://github.com/istoreos/istoreos.git"
lienol_pkg_repo="https://github.com/Lienol/openwrt-package"
openwrt_apps_repo="https://github.com/ffuqiangg/openwrt_apps.git"
passwall_pkg_repo="https://github.com/xiaorouji/openwrt-passwall-packages"
passwall_luci_repo="https://github.com/xiaorouji/openwrt-passwall"
dockerman_repo="https://github.com/lisaac/luci-app-dockerman"
diskman_repo="https://github.com/lisaac/luci-app-diskman"
docker_lib_repo="https://github.com/lisaac/luci-lib-docker"
mosdns_repo="https://github.com/sbwml/luci-app-mosdns.git"
openclash_repo="https://github.com/vernesong/OpenClash.git"
node_prebuilt_repo="https://github.com/sbwml/feeds_packages_lang_node-prebuilt"
nikki_repo="https://github.com/nikkinikki-org/OpenWrt-nikki.git"
momo_repo="https://github.com/nikkinikki-org/OpenWrt-momo.git"
v2ray_geodata_repo="https://github.com/sbwml/v2ray-geodata"
amlogic_repo="https://github.com/ophub/luci-app-amlogic.git"

clone_repo ()
{
    repo_url=$1
    branch_name=$2
    target_dir=$3
    git clone -b $branch_name --depth 1 $repo_url $target_dir
}

move_2_services ()
{
    local resource_file="$({ find | grep "\.lua\|\.htm\|\.json"; } 2>"/dev/null")"
    for a in $resource_file; do
        [ -n "$(grep "\"$1\"" $a)" ] && sed -i "s,\"$1\",\"services\",g" $a
        [ -n "$(grep "\"${1^^}\"" $a)" ] && sed -i "s,\"${1^^}\",\"Services\",g" $a
        [ -n "$(grep "\"${1^}\"" $a)" ] && sed -i "s,\"${1^}\",\"Services\",g" $a
        [ -n "$(grep "\[\[$1\]\]" $a)" ] && sed -i "s,\[\[$1\]\],\[\[services\]\],g" $a
        [ -n "$(grep "admin/$1" $a)" ] && sed -i "s,admin/$1,admin/services,g" $a
    done
}

docker_2_services ()
{
    local resource_file="$({ find | grep "\.lua\|\.htm"; } 2>"/dev/null")"
    local dockerman_lua="$({ find | grep "dockerman\.lua"; } 2>"/dev/null")"
    for a in $resource_file; do
        [ -n "$(grep 'admin\",' $a)" ] && sed -i "s|admin\",|& \"services\",|g" $a
        [ -n "$(grep 'config\")' $a)" ] && sed -i "s,config\"),overview\"),g" $a
        [ -n "$(grep 'admin/' $a)" ] && sed -i "s,admin/,&services/,g" $a
        [ -n "$(grep 'admin\\/' $a)" ] && sed -i "s,admin\\\/,&services\\\/,g" $a
    done
    sed -i 's,Docker,&Man,' $dockerman_lua
}
