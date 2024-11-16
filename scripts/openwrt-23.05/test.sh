#!/bin/bash

source ../scripts/funcations.sh

### 基础部分 ###
# 使用 O2 级别的优化
sed -i 's/Os/O2/g' include/target.mk
# 更新 Feeds
./scripts/feeds update -a
./scripts/feeds install -a

### 替换准备 ###
rm -rf feeds/packages/net/{xray-core,v2ray-core,v2ray-geodata,sing-box,microsocks,shadowsocks-libev,v2raya}

### 获取额外的 LuCI 应用和依赖 ###
mkdir -p ./package/new

# Autocore
cp -rf ../files/autocore ./package/new/autocore

### 一些后续处理 ###
makefile_file="$({ find package -type f | grep Makefile | sed "/Makefile./d"; } 2>"/dev/null")"
for g in ${makefile_file}; do
    [ -n "$(grep "golang-package.mk" "$g")" ] && sed -i "s|\.\./\.\.|$\(TOPDIR\)/feeds/packages|g" "$g"
    [ -n "$(grep "luci.mk" "$g")" ] && sed -i "s|\.\./\.\.|$\(TOPDIR\)/feeds/luci|g" "$g"
done

### 预配置一些插件 ###
mkdir -p files
cp -rf ../files/{etc,root,sing-box/*} files/

find ./ -name *.orig | xargs rm -f
find ./ -name *.rej | xargs rm -f

exit 0
