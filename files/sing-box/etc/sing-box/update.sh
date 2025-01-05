#!/bin/bash

subscription_url=""

/etc/init.d/sing-box stop

pushd /etc/sing-box
wget -q -U sing-box "${subscription_url}" -O 1.json.new
if [[ $? -eq 0 ]];then
    mv 1.json.new 1.json && jq -s add 1.json config.temp > config.json
else
    [ -f 1.json.new ] && rm -f 1.json.new
fi
popd

/etc/init.d/sing-box start

exit 0
