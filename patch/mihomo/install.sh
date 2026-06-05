#!/bin/sh
#
# 此脚本用于安装 openwrt 裸核运行 mihomo 相关文件
# 源码: https://github.com/ffuqiangg/build_openwrt/tree/main/patch/mihomo
# 文档: https://github.com/ffuqiangg/build_openwrt/blob/main/doc/mihomo.md
#

# 打印输出信息函数
red_msg() { printf "\033[1;31m%s\033[0m %s\n" "$@"; }
green_msg() { printf "\033[1;32m%s\033[0m %s\n" "$@"; }
yellow_msg() { printf "\033[1;33m%s\033[0m %s\n" "$@"; }

# 检测网络环境决定是否使用 github 代理
ip_info=$(curl -sk https://ip.cooluc.com)
country_code=$(echo $ip_info | sed -r 's/.*country_code":"([^"]*).*/\1/')
if [ $country_code = "CN" ]; then
    google_status=$(curl -I -4 -m 3 -o /dev/null -s -w %{http_code} http://www.google.com/generate_204)
    if [ ! $google_status = "204" ];then
        mirror="https://gh-proxy.com/"
    fi
fi

# 准备基础变量和目录
download_dir="https://raw.githubusercontent.com/ffuqiangg/build_openwrt/main/patch/mihomo"
[ -d "/etc/mihomo" ] || mkdir -p /etc/mihomo

# 下载文件
green_msg "Downloading:" "/etc/init.d/mihomo ..."
curl -fkL --connect-timeout 30 -m 600 -o /etc/init.d/mihomo ${mirror}${download_dir}/mihomo.init
if [ $? -ne 0 ]; then
    red_msg "Error:" "download failed. exit!"
    exit 1
fi
[ -x "/etc/init.d/mihomo" ] || chmod +x /etc/init.d/mihomo

if [ -f "/etc/mihomo/config.yaml" ]; then
    yellow_msg "Warning:" "/etc/mihomo/config.yaml exists, skip download."
else
    green_msg "Downloading:" "/etc/mihomo/config.yaml ..."
    curl -fkL --connect-timeout 30 -m 600 -o /etc/mihomo/config.yaml ${mirror}${download_dir}/config.yaml
    if [ $? -ne 0 ]; then
        red_msg "Error:" "/etc/mihomo/config.yaml download failed."
        exit 1
    fi
fi

green_msg "Success:" "All done, Enjoy! 🎉"
