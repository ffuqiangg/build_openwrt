#!/bin/sh
#
# 此脚本用于安装 openwrt 裸核运行 sing-box 相关文件
# 源码: https://github.com/ffuqiangg/build_openwrt/tree/main/patch/sing-box
# 文档: https://github.com/ffuqiangg/build_openwrt/blob/main/doc/sing-box.md
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

# 用于对比配置文件差异
compare_and_restore() {
    local BAK_FILE="/etc/config/sing-box.bak"
    local NEW_FILE="/etc/config/sing-box"

    if [ ! -f "$BAK_FILE" ]; then
        return 0
    fi

    diffs=$(awk '
        function trim(s) { sub(/^[ \t]+/, "", s); sub(/[ \t]+$/, "", s); return s }
        NR==FNR {
            line = trim($0)
            if (line ~ /^$/ || line ~ /^#/) next
            if ($1 == "config") { ctx = $1 " " $2 " " $3; f1[ctx] = 1 }
            else if ($1 == "option" || $1 == "list") { f1[ctx "->" $1 " " $2] = 1 }
            next
        }
        {
            line = trim($0)
            if (line ~ /^$/ || line ~ /^#/) next
            if ($1 == "config") { ctx = $1 " " $2 " " $3; f2[ctx] = 1; if(!(ctx in f1)) print "new" }
            else if ($1 == "option" || $1 == "list") { key = ctx "->" $1 " " $2; f2[key] = 1; if(!(key in f1)) print "new" }
        }
        END { for (k in f1) { if (!(k in f2)) print "del" } }
    ' "$BAK_FILE" "$NEW_FILE")

    if [ -z "$diffs" ]; then
        mv "$BAK_FILE" "$NEW_FILE"
    fi
}

# 准备基础变量，处理目录和文件
download_dir="https://raw.githubusercontent.com/ffuqiangg/build_openwrt/main/patch/sing-box/ucode"
for dir in scripts resources run profiles; do mkdir -p /etc/sing-box/${dir}; done
[ -x "/sbin/fw4" ] && firewall='nftables' || firewall='iptables'
[ -f "/etc/sing-box/config.json" ] && rm -f /etc/sing-box/config.json

# 下载文件
green_msg "Downloading:" "/etc/init.d/sing-box ..."
curl -fkL --connect-timeout 30 -m 600 -o /etc/init.d/sing-box ${mirror}${download_dir}/${firewall}/sing-box.init
if [ $? -ne 0 ]; then
    red_msg "Error:" "/etc/init.d/sing-box download failed."
    exit 1
fi
[ -x "/etc/init.d/sing-box" ] || chmod +x /etc/init.d/sing-box

green_msg "Downloading:" "/etc/config/sing-box ..."
[ -f "/etc/config/sing-box" ] && mv /etc/config/sing-box /etc/config/sing-box.bak
curl -fkL --connect-timeout 30 -m 600 -o /etc/config/sing-box ${mirror}${download_dir}/generic/sing-box.conf
if [ $? -ne 0 ]; then
    [ -f "/etc/config/sing-box.bak" ] && mv /etc/config/sing-box.bak /etc/config/sing-box
    red_msg "Error:" "/etc/config/sing-box download failed."
    exit 1
fi
compare_and_restore
[ -f "/etc/config/sing-box.bak" ] && yellow_msg "Backupfile:" "/etc/config/sing-box.bak!"

green_msg "Downloading:" "/etc/sing-box/scripts/generate_config.uc ..."
curl -fkL --connect-timeout 30 -m 600 -o /etc/sing-box/scripts/generate_config.uc ${mirror}${download_dir}/generic/generate_config.uc
if [ $? -ne 0 ]; then
    [ -f "/etc/config/sing-box.bak" ] && mv /etc/config/sing-box.bak /etc/config/sing-box
    red_msg "Error:" "/etc/sing-box/scripts/generate_config.uc download failed."
    exit 1
fi

green_msg "Downloading:" "/etc/sing-box/scripts/firewall_post.ut ..."
curl -fkL --connect-timeout 30 -m 600 -o /etc/sing-box/scripts/firewall_post.ut ${mirror}${download_dir}/${firewall}/firewall_post.ut
if [ $? -ne 0 ]; then
    [ -f "/etc/config/sing-box.bak" ] && mv /etc/config/sing-box.bak /etc/config/sing-box
    red_msg "Error:" "/etc/sing-box/scripts/firewall_post.ut download failed."
    exit 1
fi

green_msg "Downloading:" "/etc/sing-box/resources/china_ip4.txt ..."
curl -fkL --connect-timeout 30 -m 600 -o /etc/sing-box/resources/china_ip4.txt ${mirror}${download_dir}/${firewall}/china_ip4.txt
if [ $? -ne 0 ]; then
    [ -f "/etc/config/sing-box.bak" ] && mv /etc/config/sing-box.bak /etc/config/sing-box
    red_msg "Error:" "/etc/sing-box/resources/china_ip4.txt download failed."
    exit 1
fi

green_msg "Downloading:" "/etc/sing-box/resources/stream.json ..."
curl -fkL --connect-timeout 30 -m 600 -o /etc/sing-box/resources/stream.json ${mirror}${download_dir}/generic/stream.json
if [ $? -ne 0 ]; then
    [ -f "/etc/config/sing-box.bak" ] && mv /etc/config/sing-box.bak /etc/config/sing-box
    red_msg "Error:" "/etc/sing-box/resources/stream.json download failed."
    exit 1
fi

echo "🎉 All done. Enjoy!"
