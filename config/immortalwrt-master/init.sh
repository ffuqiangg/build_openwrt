#!/bin/bash

# Change banner
echo -e "[34m[0m Immortalwrt Master" > /etc/banner
echo -e "[34m[0m COMPILE_DATE build by ffuqiangg" >> /etc/banner

# Modify rootfs size on emmc
sed -i -e '/ROOT1=/c ROOT1=\"720\"' -e '/ROOT2=/c ROOT2=\"720\"' /usr/sbin/openwrt-install-amlogic
