#!/bin/sh
. /etc/init.d/sing-box
url=""

/etc/init.d/sing-box stop 2>/dev/null

curl --user-agent sing-box --connect-timeout 30 -m 600 -klo ${RES_DIR}1.json.new $url
if [ $? -eq 0 ];then
    mv ${RES_DIR}1.json.new ${RES_DIR}1.json && jq -s add ${RES_DIR}1.json ${RES_DIR}template.json > ${RES_DIR}config.json
else
    [ -f ${RES_DIR}1.json.new ] && rm -f ${RES_DIR}1.json.new
    echo "Warning! 订阅下载失败，请重试 ..."
fi

/etc/init.d/sing-box start

exit 0
