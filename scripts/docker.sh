#
# 本脚本用于将 dockerman 从一级菜单移动到 服务 菜单中
#

resource_file=$(find . -type f -name "*.lua" -o -name "*.htm")
dockerman_lua=$(find . -type f -name "dockerman.lua")

for a in $resource_file; do
    [ -n "$(grep '"admin",' $a)" ] && sed -i 's|"admin",|& "services",|g' $a
    [ -n "$(grep 'admin/' $a)" ] && sed -i 's,admin/,&services/,g' $a
    [ -n "$(grep 'admin\\/' $a)" ] && sed -i 's,admin\\\/,&services\\\/,g' $a
done

sed -i -e 's,Docker,&Man,' -e 's,"config"),"overview"),g' $dockerman_lua

exit 0