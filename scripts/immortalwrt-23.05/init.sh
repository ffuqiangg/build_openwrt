#!/bin/bash

# Change banner
echo -e "\n[34m▍[0mImmortalwrt VERSION" > /etc/banner
echo -e "[34m▍[0mDATE build by ffuqiangg\n" >> /etc/banner

# Delete 30-sysinfo.sh
rm /etc/profile.d/30-sysinfo.sh

# Modify rootfs size on emmc
sed -i -e '/ROOT1=/c ROOT1=\"720\"' -e '/ROOT2=/c ROOT2=\"720\"' /usr/sbin/openwrt-install-amlogic
