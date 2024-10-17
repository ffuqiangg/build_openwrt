#!/bin/bash

makefile_file="$({ find package -type f | grep Makefile | sed "/Makefile./d"; } 2>"/dev/null")"
for g in ${makefile_file}; do
    [ -n "$(grep "golang-package.mk" "$g")" ] && sed -i "s|\.\./\.\.|$\(TOPDIR\)/feeds/packages|g" "$g"
    [ -n "$(grep "luci.mk" "$g")" ] && sed -i "s|\.\./\.\.|$\(TOPDIR\)/feeds/luci|g" "$g"
done

exit 0
