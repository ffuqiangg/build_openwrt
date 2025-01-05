#!/bin/bash

subscription_url=""

/etc/init.d/sing-box stop

if [[ ${1}a == stopa ]]; then
    /etc/init.d/sing-box disable 2>/dev/null
    sed -i '/sing-box\/update.sh/d' /etc/crontabs/root
    exit 0
fi

pushd /etc/sing-box
wget -q -U sing-box "${subscription_url}" -O 1.json.new
if [[ $? -eq 0 ]];then
    mv 1.json.new 1.json && jq -s add 1.json config.temp > config.json
else
    [ -f 1.json.new ] && rm -f 1.json.new
fi
popd

/etc/init.d/sing-box start

[[ -z $(ls /etc/rc.d | grep sing-box) ]] && /etc/init.d/sing-box enable
[[ -z $(grep sing-box/update.sh /etc/crontabs/root) ]] && echo "0 5 * * * /etc/sing-box/update.sh" >> /etc/crontabs/root

exit 0
