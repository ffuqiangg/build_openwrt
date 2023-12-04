#!/bin/bash

sed -i -e '/ROOT1=/c\ROOT1=\"720\"' -e '/ROOT2=/c\ROOT2=\"720\"' /usr/sbin/openwrt-install-amlogic

uci set luci.main.lang=zh_cn
uci commit luci

uci set system.@system[0].timezone=CST-8
uci set system.@system[0].zonename=Asia/Shanghai
uci commit system

exit 0