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

echo -e "\r\n${GREEN_COLOR}INFO${RES} Download files ...\r\n"

# prepare
download_dir="https://raw.githubusercontent.com/ffuqiangg/build_openwrt/main/patch/sing-box/tun"
[ -d /etc/sing-box ] && rm -rf /etc/sing-box && mkdir -p /etc/sing-box

# download
echo -e "${GREEN_COLOR}INFO${RES} Download Sing-box init ..."
curl --connect-timeout 30 -m 600 -kLo /etc/init.d/sing-box $mirror${download_dir}/sing-box.init
if [ $? -ne 0 ]; then
    echo -e "${RED_COLOR}ERROR${RES} download Sing-box init failed."
    exit 1
fi
echo -e "${GREEN_COLOR}INFO${RES} Download sing-box config ..."
curl --connect-timeout 30 -m 600 -kLo /etc/config/sing-box $mirror${download_dir}/sing-box.conf
if [ $? -ne 0 ]; then
    echo -e "${RED_COLOR}ERROR${RES} download sing-box.json failed."
    exit 1
fi
echo -e "${GREEN_COLOR}INFO${RES} Fix permissions ...\n"
chmod +x /etc/init.d/sing-box
if [ $? -ne 0 ]; then
    echo -e "${RED_COLOR}ERROR${RES} fix permissions failed."
    exit 1
fi

echo -e "${GREEN_COLOR}INFO${RES} Done!"
