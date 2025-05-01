#!/bin/sh

conffile=$(uci -q get sing-box.main.conffile); conffile=${conffile:-"/etc/sing-box/config.json"}
workdir=$(uci -q get sing-box.main.workdir); workdir=${workdir:-"/etc/sing-box"}
remote=$(uci -q get sing-box.subscription.remote); remote=${remote:-"1"}
level=$(uci -q get sing-box.log.level); level=${level:-"warn"}
output=$(uci -q get sing-box.log.output); output=${output:-"/var/log/sing-box.log"}
external_controller_port=$(uci -q get sing-box.experimental.external_controller_port); external_controller_port=${external_controller_port:-"9090"}
external_ui=$(uci -q get sing-box.experimental.external_ui); external_ui=${external_ui:-"ui"}
secret=$(uci -q get sing-box.experimental.secret); secret=${secret:-"ffuqiangg"}
ui_name=$(uci -q get sing-box.experimental.ui_name); ui_name=${ui_name:-"metacubexd"}
default_mode=$(uci -q get sing-box.experimental.default_mode); default_mode=${default_mode:-"rule"}
store_fakeip=$(uci -q get sing-box.experimental.store_fakeip); store_fakeip=${store_fakeip:-"0"}
store_rdrc=$(uci -q get sing-box.experimental.store_rdrc); store_rdrc=${store_rdrc:-"0"}
tproxy_port=$(uci -q get sing-box.inbounds.tproxy_port); tproxy_port=${tproxy_port:-"10105"}
mixed_port=$(uci -q get sing-box.inbounds.mixed_port); mixed_port=${mixed_port:-"2080"}
dns_port=$(uci -q get sing-box.inbounds.dns_port); dns_port=${dns_port:-"2053"}

if [ "$store_fakeip" = "1" ]; then store_fakeip='true'; else store_fakeip='false'; fi
if [ "$store_rdrc" = "1" ]; then store_rdrc='true'; else store_rdrc='false'; fi

[ "$ui_name" = "metacubexd" ] && ui_url='https://github.com/MetaCubeX/metacubexd/archive/refs/heads/gh-pages.zip'
[ "$ui_name" = "zashboard" ] && ui_url='https://github.com/Zephyruso/zashboard/releases/latest/download/dist.zip'
[ "$ui_name" = "yacd" ] && ui_url='https://github.com/MetaCubeX/Yacd-meta/archive/refs/heads/gh-pages.zip'

if [ "$remote" = "0" ]; then
    profile_file="$workdir/sing-box.json"
elif [ "$remote" -ge "1" ]; then
    profile_file="$workdir/subscription$remote.json"
fi

outbounds_direct_tag=$(jq -r '.outbounds[] | select(.type=="direct") | .tag' $profile_file)
outbounds_block_tag=$(jq -r '.outbounds[] | select(.type=="block") | .tag' $profile_file)

log="{
        \"disabled\":false,
        \"level\":\"$level\",
        \"output\":\"$output\",
        \"timestamp\":true
    }"
experimental="{
    \"clash_api\":{
        \"external_controller\":\"0.0.0.0:$external_controller_port\",
        \"external_ui\":\"$external_ui\",
        \"secret\":\"$secret\",
        \"external_ui_download_url\":\"https://gh-proxy.com/$ui_url\",
        \"external_ui_download_detour\":\"$outbounds_direct_tag\",
        \"default_mode\":\"$default_mode\"},
    \"cache_file\":{
        \"enabled\":true,
        \"store_fakeip\":$store_fakeip,
        \"store_rdrc\":$store_rdrc}
    }"
inbounds="[{
        \"type\":\"tproxy\",
        \"tag\":\"tproxy-in\",
        \"listen\":\"::\",
        \"listen_port\":$tproxy_port
    },{
        \"type\":\"mixed\",
        \"tag\":\"mixed-in\",
        \"listen\":\"::\",
        \"listen_port\":$mixed_port
    },{
        \"type\":\"direct\",
        \"tag\":\"dns-in\",
        \"listen\":\"::\",
        \"listen_port\":$dns_port
    }]"

route_rules_dns='[{"action":"sniff"},{"inbound":"dns-in","action":"hijack-dns"}]'

if [ -n "$(jq '.route.rules[] | select(.action)' $profile_file)" ]; then
    route_rules=$(cat $profile_file | \
        jq --argjson route_rules_dns $route_rules_dns \
        '.route.rules |
        del(.[] | select(.action=="sniff" or .action=="hijack-dns" or .action=="resolve")) |
        $route_rules_dns + .')
    jq --argjson log "$log" \
       --argjson experimental "$experimental" \
       --argjson inbounds "$inbounds" \
       --argjson route_rules "$route_rules" \
       '.log=$log | .experimental=$experimental | .inbounds=$inbounds | .route.rules=$route_rules' \
       $profile_file \
       > $conffile
else
    route_rules=$(cat $profile_file | \
        jq --argjson route_rules_dns $route_rules_dns \
        '.route.rules |
        del(.[] | select(.protocol=="dns")) |
        $route_rules_dns + .' | \
        sed "s/\"outbound\": \"$outbounds_block_tag\"/\"action\": \"reject\"/g")
    jq --argjson log "$log" \
       --argjson experimental "$experimental" \
       --argjson inbounds "$inbounds" \
       --argjson route_rules "$route_rules" \
       '.log=$log | .experimental=$experimental | .inbounds=$inbounds | .route.rules=$route_rules' \
       $profile_file | \
       jq 'del(.outbounds[] | select(.type=="dns" or .type=="block"))' \
       > $conffile
fi
