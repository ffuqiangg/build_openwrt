#!/bin/bash

lua_file="$({ find | grep "\.lua\|\.htm\|\.json"; } 2>"/dev/null")"
for a in ${lua_file}
do
    [ -n "$(grep '"vpn"' "$a")" ] && sed -i 's,"vpn","services",g' "$a"
    [ -n "$(grep '"VPN"' "$a")" ] && sed -i 's,"VPN","Services",g' "$a"
    [ -n "$(grep '\[\[vpn\]\]' "$a")" ] && sed -i 's,\[\[vpn\]\],\[\[services\]\],g' "$a"
    [ -n "$(grep 'admin/vpn' "$a")" ] && sed -i 's,admin/vpn,admin/services,g' "$a"
    [ -n "$(grep "\"nas\"" "$a")" ] && sed -i "s,\"nas\",\"services\",g" "$a"
    [ -n "$(grep "\"NAS\"" "$a")" ] && sed -i "s,\"NAS\",\"Services\",g" "$a"
    [ -n "$(grep "\[\[nas\]\]" "$a")" ] && sed -i "s,\[\[nas\]\],\[\[services\]\],g" "$a"
    [ -n "$(grep "admin/nas" "$a")" ] && sed -i "s,admin/nas,admin/services,g" "$a"
done

exit 0
