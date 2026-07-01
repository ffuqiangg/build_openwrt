#!/bin/sh
#
# 此脚本用于安装 openwrt 裸核运行 mihomo 相关文件
# 源码: https://github.com/ffuqiangg/build_openwrt/tree/main/patch/mihomo
# 文档: https://github.com/ffuqiangg/build_openwrt/blob/main/doc/mihomo.md
#

# --- 检测网络环境决定是否使用 github 代理 ---
ip_info=$(curl -sk https://ip.cooluc.com)
country_code=$(echo $ip_info | sed -r 's/.*country_code":"([^"]*).*/\1/')
if [ $country_code = "CN" ]; then
    google_status=$(curl -I -4 -m 3 -o /dev/null -s -w %{http_code} http://www.google.com/generate_204)
    if [ ! $google_status = "204" ];then
        mirror="https://gh-proxy.com/"
    fi
fi

# --- 准备基础变量和目录 ---
download_dir="https://raw.githubusercontent.com/ffuqiangg/build_openwrt/main/patch/mihomo"
[ -d "/etc/mihomo" ] || mkdir -p /etc/mihomo

# --- 准备文件 ---
echo -e "\033[1;34m::\033[0m Installing mihomo scripts:"
echo -n '(1/2) /etc/init.d/mihomo ... '
if curl -fkL --connect-timeout 30 -m 600 -o /etc/init.d/mihomo ${mirror}${download_dir}/mihomo.init > /dev/null 2>&1; then
    echo -e "\033[1;32mdone\033[0m"
    [ -x "/etc/init.d/mihomo" ] || chmod +x /etc/init.d/mihomo
else
    echo -e "\033[1;31mfailed\033[0m"
    exit 1
fi

echo -n '(2/2) /etc/mihomo/config.yaml ... '
if [ -f "/etc/mihomo/config.yaml" ]; then
    echo -e "\033[1;33mskip\033[0m"
else
    if curl -fkL --connect-timeout 30 -m 600 -o /etc/mihomo/config.yaml ${mirror}${download_dir}/config.yaml > /dev/null 2>&1; then
        echo -e "\033[1;32mdone\033[0m"
    else
        echo -e "\033[1;31mfailed\033[0m"
        exit 1
    fi
fi

echo -e "🎉 All done, Enjoy!"
