#!/bin/bash
#
# 本脚本用于将 dockerman 从一级菜单移动到 服务 菜单中
#

resource_file="$({ find | grep "\.lua|\.htm"; } 2>"/dev/null")"
  for a in $resource_file; do
    [ -n "$(grep 'admin\",' $a)" ] && sed -i "s|admin\",|& \"services\",|g" $a
    [ -n "$(grep 'config\")' $a)" ] && sed -i "s,config\"),overview\"),g" $a
    [ -n "$(grep 'admin/' $a)" ] && sed -i "s,admin/,&services/,g" $a
    [ -n "$(grep 'admin\\/' $a)" ] && sed -i "s,admin\\\/,&services\\\/,g" $a
  done

dockerman_lua="$({ find | grep "dockerman\.lua"; } 2>"/dev/null")"
sed -i 's,Docker,&Man,' $dockerman_lua

exit 0
