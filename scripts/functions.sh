#!/bin/bash

openwrt_repo="https://github.com/openwrt/openwrt"
openwrt_pkg_repo="https://github.com/openwrt/packages"
openwrt_luci_repo="https://github.com/openwrt/luci"
immortalwrt_repo="https://github.com/immortalwrt/immortalwrt"
immortalwrt_pkg_repo="https://github.com/immortalwrt/packages"
immortalwrt_luci_repo="https://github.com/immortalwrt/luci"
lede_repo="https://github.com/coolsnowwolf/lede"
lede_pkg_repo="https://github.com/coolsnowwolf/packages"
lede_luci_repo="https://github.com/coolsnowwolf/luci"
istoreos_repo="https://github.com/istoreos/istoreos"
lienol_pkg_repo="https://github.com/Lienol/openwrt-package"
passwall_pkg_repo="https://github.com/xiaorouji/openwrt-passwall-packages"
passwall_luci_repo="https://github.com/xiaorouji/openwrt-passwall"
dockerman_repo="https://github.com/lisaac/luci-app-dockerman"
diskman_repo="https://github.com/lisaac/luci-app-diskman"
docker_lib_repo="https://github.com/lisaac/luci-lib-docker"
openwrt_mosdns_repo="https://github.com/QiuSimons/openwrt-mos"
sbwml_mosdns_repo="https://github.com/sbwml/luci-app-mosdns"
mosdns_geodata_repo="https://github.com/sbwml/v2ray-geodata"
openclash_repo="https://github.com/vernesong/OpenClash"
node_prebuilt_repo="https://github.com/sbwml/feeds_packages_lang_node-prebuilt"
nikki_repo="https://github.com/nikkinikki-org/OpenWrt-nikki"
momo_repo="https://github.com/nikkinikki-org/OpenWrt-momo"
v2ray_geodata_repo="https://github.com/sbwml/v2ray-geodata"
amlogic_repo="https://github.com/ophub/luci-app-amlogic"
daed_repo="https://github.com/QiuSimons/luci-app-daed"
helloworld_repo="https://github.com/sbwml/openwrt_helloworld"
sbwml_pkgs_repo="https://github.com/sbwml/openwrt_pkgs"
v2raya_repo="https://github.com/zxlhhyccc/luci-app-v2raya"
autocore_arm_repo="https://github.com/sbwml/autocore-arm"
homeproxy_repo="https://github.com/immortalwrt/homeproxy"

clone_repo ()
{
    repo_url=$1
    branch_name=$2
    target_dir=$3
    git clone --single-branch -b $branch_name --depth 1 $repo_url $target_dir
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
