#!/bin/bash

sed -i -e '/ROOT1=/c\ROOT1=\"720\"' -e '/ROOT2=/c\ROOT2=\"720\"' /usr/sbin/openwrt-install-amlogic

exit 0