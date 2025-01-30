#!/bin/sh
RED_COLOR='\e[1;31m'
GREEN_COLOR='\e[1;32m'
RES='\e[0m'

# GitHub mirror
ip_info=$(curl -sk https://ip.cooluc.com)
country_code=$(echo $ip_info | sed -r 's/.*country_code":"([^"]*).*/\1/')
if [ $country_code = "CN" ]; then
    google_status=$(curl -I -4 -m 3 -o /dev/null -s -w %{http_code} http://www.google.com/generate_204)
    if [ ! $google_status = "204" ];then
        mirror="https://gh-proxy.com/"
    fi
fi

echo -e "\r\n${GREEN_COLOR}Download files ...${RES}\r\n"

# prepare
download_dir="https://raw.githubusercontent.com/ffuqiangg/build_openwrt/main/patch/sing-box/tun"
[ -d /etc/sing-box ] && rm -rf /etc/sing-box && mkdir -p /etc/sing-box

# download
echo -e "${GREEN_COLOR}Download Sing-box init ...${RES}"
curl --connect-timeout 30 -m 600 -kLo /etc/init.d/sing-box $mirror${download_dir}/sing-box.init
if [ $? -ne 0 ]; then
    echo -e "${RED_COLOR}Error! download Sing-box init failed.${RES}"
    exit 1
fi
echo -e "${GREEN_COLOR}Download sing-box config file ...${RES}"
curl --connect-timeout 30 -m 600 -kLo /etc/config/sing-box $mirror${download_dir}/sing-box.conf
if [ $? -ne 0 ]; then
    echo -e "${RED_COLOR}Error! download sing-box.json failed.${RES}"
    exit 1
fi
echo -e "${GREEN_COLOR}Fix permissions ...${RES}\n"
chmod +x /etc/init.d/sing-box
if [ $? -ne 0 ]; then
    echo -e "${RED_COLOR}Error! fix permissions failed.${RES}"
    exit 1
fi

echo -e "${GREEN_COLOR}Done!${RES}"
