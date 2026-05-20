#!/bin/sh
#
# 此脚本用于安装 openwrt 裸核运行 mihomo 相关文件
# 源码: https://github.com/ffuqiangg/build_openwrt/tree/main/patch/mihomo
# 文档: https://github.com/ffuqiangg/build_openwrt/blob/main/doc/mihomo.md
#

# 打印输出信息函数
erro() { printf "\033[1;31mERRO\033[0m %s\n" "$@"; }
info() { printf "\033[1;36mINFO\033[0m %s\n" "$@"; }
warn() { printf "\033[1;33mWARN\033[0m %s\n" "$@"; }

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
if curl -fkL --connect-timeout 30 -m 600 -o /etc/init.d/mihomo ${mirror}${download_dir}/mihomo.init > /dev/null 2>&1; then
    info "Download mihomo.init success."
else
    erro "Download mihomo.init failed."
    exit 1
fi
[ -x "/etc/init.d/mihomo" ] || chmod +x /etc/init.d/mihomo

if [ -f "/etc/mihomo/config.yaml" ]; then
    warn "Mihomo config exists, skip download."
else
    if curl -fkL --connect-timeout 30 -m 600 -o /etc/mihomo/config.yaml ${mirror}${download_dir}/config.yaml > /dev/null 2>&1; then
        info "Download mihomo config success."
    else
        erro "Download mihomo config failed."
        exit 1
    fi
fi

info "Everything is fine, Enjoy🎉"
