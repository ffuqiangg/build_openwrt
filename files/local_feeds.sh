#!/bin/sh
build_date=$(grep -oE "[0-9]{4}\.[0-9]{2}\.[0-9]{2}" /etc/banner)
download_url="https://github.com/ffuqiangg/build_openwrt/releases/download/${build_date}/"
if [ $(grep -c "LEDE" /etc/openwrt_release) -ne 0 ]; then
    openwrt_revision=$(grep 'DISTRIB_REVISION=' /etc/openwrt_release | sed -E "s/.*'(.+)'.*/\1/")
    download_file="N1-LEDE-${openwrt_revision}-${build_date}-packages.zip"
elif [ $(grep -c "iStoreOS" /etc/openwrt_release) -ne 0 ]; then
    download_file="N1-iStoreOS-${build_date}-packages.zip"
fi

# GitHub mirror
ip_info=$(curl -sk https://ip.cooluc.com)
country_code=$(echo $ip_info | sed -r 's/.*country_code":"([^"]*).*/\1/')
if [ $country_code = "CN" ]; then
    google_status=$(curl -I -4 -m 3 -o /dev/null -s -w %{http_code} http://www.google.com/generate_204)
    if [ ! $google_status = "204" ];then
        mirror="https://gh-proxy.com/"
    fi
fi

# download
curl --connect-timeout 30 -m 600 -kLo /www/packages.zip ${mirror}${download_url}${download_file}

# Unzip file
cd /www && unzip packages.zip && rm -rf packages.zip

# Modify distfeeds.conf
if [ $(grep -c "LEDE" /etc/openwrt_release) -ne 0 ]; then
    sed -i '/openwrt_core/c src\/gz openwrt_core file:\/\/\/www\/packages' /etc/opkg/distfeeds.conf
elif [ $(grep -c "iStoreOS" /etc/openwrt_release) -ne 0 ]; then
    sed -i '$a src\/gz openwrt_core file:\/\/\/www\/packages' /etc/opkg/compatfeeds.conf
fi

opkg update

exit 0
