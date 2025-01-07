#!/bin/bash

url="" # 订阅地址
work_dir="/etc/sing-box"

/etc/init.d/sing-box stop

curl --user-agent sing-box --connect-timeout 30 -m 600 -klo ${work_dir}/1.json.new $url
if [ $? -eq 0 ];then
    mv ${work_dir}/1.json.new ${work_dir}/1.json && jq -s add ${work_dir}/1.json ${work_dir}/template.json > ${work_dir}/config.json
else
    [ -f ${work_dir}/1.json.new ] && rm -f ${work_dir}/1.json.new
fi

/etc/init.d/sing-box start

exit 0
