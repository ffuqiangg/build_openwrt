#!/bin/sh
RED_COLOR='\e[1;31m'
GREEN_COLOR='\e[1;32m'
RES='\e[0m'

# 检测网络环境并配置 Github 镜像
ip_info=$(curl -sk https://ip.cooluc.com)
country_code=$(echo $ip_info | sed -r 's/.*country_code":"([^"]*).*/\1/')
if [ $country_code = "CN" ]; then
    google_status=$(curl -I -4 -m 3 -o /dev/null -s -w %{http_code} http://www.google.com/generate_204)
    if [ ! $google_status = "204" ];then
        mirror="https://gh-proxy.com/"
    fi
fi

# 下载文件
echo -e "${GREEN_COLOR}INFO${RES} Download Mihomo init ..."
curl --connect-timeout 30 -m 600 -kLo /etc/init.d/mihomo ${mirror}https://raw.githubusercontent.com/ffuqiangg/build_openwrt/dev/patch/mihomo/mihomo.init
if [ $? -ne 0 ]; then
    echo -e "${RED_COLOR}ERROR${RES} download Mihomo init failed."
    exit 1
fi
echo -e "${GREEN_COLOR}INFO${RES} Download Mihomo config ..."
mkdir -p /etc/mihomo
curl --connect-timeout 30 -m 600 -kLo /etc/mihomo/config.yaml ${mirror}https://raw.githubusercontent.com/ffuqiangg/build_openwrt/dev/patch/mihomo/config.yaml
if [ $? -ne 0 ]; then
    echo -e "${RED_COLOR}ERROR${RES} download Mihomo config failed."
    exit 1
fi

# 设置权限
echo -e "${GREEN_COLOR}INFO${RES} Fix permissions ...\n"
chmod +x /etc/init.d/mihomo
if [ $? -ne 0 ]; then
    echo -e "${RED_COLOR}ERROR${RES} fix permissions failed."
    exit 1
fi

echo -e "${GREEN_COLOR}INFO${RES} Done."
