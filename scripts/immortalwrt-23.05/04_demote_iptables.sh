#!/bin/bash

# 回滚 iptables 为 1.8.7（1.8.8有一个致命bug，当上游升级至1.8.9时可以去除下面3行；具体参见https://www.netfilter.org/projects/iptables/files/changes-iptables-1.8.9.txt）
rm -rf ./package/network/utils/iptables
cp -rf ../openwrt_22/package/network/utils/iptables ./package/network/utils/iptables
wget -P ./package/network/utils/iptables/patches/ https://github.com/coolsnowwolf/lede/raw/master/package/network/utils/iptables/patches/900-bcm-fullconenat.patch

exit 0
