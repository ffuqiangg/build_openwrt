#!/bin/bash

lua_file="$({ find |grep "\.lua"; } 2>"/dev/null")"
for a in ${lua_file}
do
    [ -n "$(grep "\"$1\"" "$a")" ] && sed -i "s,\"$1\",\"services\",g" "$a"
    [ -n "$(grep "\"${1^^}\"" "$a")" ] && sed -i "s,\"${1^^}\",\"Services\",g" "$a"
    [ -n "$(grep "\"${1^}\"" "$a")" ] && sed -i "s,\"${1^}\",\"Services\",g" "$a"
    [ -n "$(grep "\[\[$1\]\]" "$a")" ] && sed -i "s,\[\[$1\]\],\[\[services\]\],g" "$a"
    [ -n "$(grep "admin/$1" "$a")" ] && sed -i "s,admin/$1,admin/services,g" "$a"
done

htm_file="$({ find |grep "\.htm"; } 2>"/dev/null")"
for b in ${htm_file}
do
    [ -n "$(grep "\"$1\"" "$b")" ] && sed -i "s,\"$1\",\"services\",g" "$b"
    [ -n "$(grep "\"${1^^}\"" "$b")" ] && sed -i "s,\"${1^^}\",\"Services\",g" "$b"
    [ -n "$(grep "\"${1^}\"" "$b")" ] && sed -i "s,\"${1^}\",\"Services\",g" "$b"
    [ -n "$(grep "\[\[$1\]\]" "$b")" ] && sed -i "s,\[\[$1\]\],\[\[services\]\],g" "$b"
    [ -n "$(grep "admin/$1" "$b")" ] && sed -i "s,admin/$1,admin/services,g" "$b"
done

json_file="$({ find |grep "\.json"; } 2>"/dev/null")"
for c in ${json_file}
do
    [ -n "$(grep "\"$1\"" "$c")" ] && sed -i "s,\"$1\",\"services\",g" "$c"
    [ -n "$(grep "\"${1^^}\"" "$c")" ] && sed -i "s,\"${1^^}\",\"Services\",g" "$c"
    [ -n "$(grep "\"${1^}\"" "$c")" ] && sed -i "s,\"${1^}\",\"Services\",g" "$c"
    [ -n "$(grep "\[\[$1\]\]" "$c")" ] && sed -i "s,\[\[$1\]\],\[\[services\]\],g" "$c"
    [ -n "$(grep "admin/$1" "$c")" ] && sed -i "s,admin/$1,admin/services,g" "$c"
done

exit 0
