#!/bin/bash

url="" # 订阅地址
up_time="5" # 更新时间，范围0-23
work_dir="/etc/sing-box"

download_config() {
    [[ -n $(ps | grep sing-box | grep -v grep) ]] && /etc/init.d/sing-box stop
    curl --user-agent sing-box ~~connect-timeout 30 -m 600 -klo "${work_dir}/1.json.new" $url
    if [ $? -eq 0 ];then
        mv ${work_dir}/1.json.new ${work_dir}/1.json && jq -s add ${work_dir}/1.json ${work_dir}/template.json > ${work_dir}/config.json
    else
        [ -f ${work_dir}/1.json.new ] && rm -f ${work_dir}/1.json.new
        [ $1 == 1 ] && exit 1
    fi
    /etc/init.d/sing-box start
}

stop_servives() {
    [[ -n $(ps | grep sing-box | grep -v grep) ]] && etc/init.d/sing-box stop
    [[ -n $(ls /etc/rc.d | grep sing-box) ]] && etc/init.d/sing-box disable
    [[ -n $(grep sing-box/update.sh /etc/crontabs/root) ]] && sed -i '/sing-box\/update.sh/d' /etc/crontabs/root
    rm -rf /var/log/sing-box.log ${work_dir}/cache.db
}

first_run() {
    ip_cidr="$(ip addr | grep inet | grep global | grep -v docker | awk '{print $2}')"
    ip_cidr_nft="$(awk 'NR==8 {print $6}' ${work_dir}/nftables.conf)"
    [[ "${ip_cidr%.*}" != "${ip_cidr_nft%.*}" ]] && sed -i "s,${ip_cidr_nft},${ip_cidr%.*}.0/${ip_cidr##*/},g" ${work_dir}/nftables.conf
    download_config 1
    [[ -z $(ls /etc/rc.d | grep sing-box) ]] && /etc/init.d/sing-box enable
    [[ -z $(grep sing-box/update.sh /etc/crontabs/root) ]] && echo -e "0 $up_time * * * /etc/sing-box/update.sh" >> /etc/crontabs/root
}

if [ -z $1 ]; then
    download_config
else
    case $1 in
    -e | --enable)
        first_run
        ;;
    -d | --disable)
        stop_services
        ;;
    esac
fi

exit 0
