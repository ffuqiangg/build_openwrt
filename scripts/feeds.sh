#!/bin/sh
#
# 此脚本用于部署本地 kmod 源
#

# --- 准备基础变量 ---
source /etc/openwrt_release
[ ! -n "$BUILD_DATE" ] && BUILD_DATE=$(grep -oE "[0-9]{4}\.[0-9]{2}\.[0-9]{2}" /etc/banner)
download_url="https://github.com/ffuqiangg/build_openwrt/releases/download/${BUILD_DATE}/"
if [ $(echo "$DISTRIB_DESCRIPTION" | grep -c 'LEDE') -ne 0 ]; then
    download_file="N1-LEDE-${DISTRIB_REVISION}-${BUILD_DATE}-packages.zip"
elif [ $(echo "$DISTRIB_DESCRIPTION" | grep -c 'iStoreOS') -ne 0 ]; then
    download_file="N1-iStoreOS-${DISTRIB_RELEASE}-${BUILD_DATE}-packages.zip"
fi

# --- 检测网络环境决定是否使用 github 代理 ---
ip_info=$(curl -sk https://ip.cooluc.com)
country_code=$(echo $ip_info | sed -r 's/.*country_code":"([^"]*).*/\1/')
if [ $country_code = "CN" ]; then
    google_status=$(curl -I -4 -m 3 -o /dev/null -s -w %{http_code} http://www.google.com/generate_204)
    if [ ! $google_status = "204" ];then
        mirror="https://gh-proxy.com/"
    fi
fi

# --- 准备文件 ---
curl -fkL --connect-timeout 30 -m 600 -o /www/packages.zip ${mirror}${download_url}${download_file}
if [ $? -ne 0 ]; then
    echo -e "\033[1;31mE\033[0m Packages download failed. Exit!"
    exit 1
fi
rm -rf /www/packages && unzip -q /www/packages.zip -d /www/ && rm -f /www/packages.zip

# --- 调整 distfeeds.conf ---
if [ $(echo "$DISTRIB_DESCRIPTION" | grep -c 'LEDE') -ne 0  ]; then
    sed -i '/openwrt_core/c src\/gz openwrt_core file:\/\/\/www\/packages' /etc/opkg/distfeeds.conf
elif [ $(echo "$DISTRIB_DESCRIPTION" | grep -c 'iStoreOS') -ne 0 ]; then
    sed -i '/www\/packages/d' /etc/opkg/compatfeeds.conf && \
    sed -i '$a src\/gz openwrt_core file:\/\/\/www\/packages' /etc/opkg/compatfeeds.conf
fi

# --- 更新源 ---
opkg update

exit 0
