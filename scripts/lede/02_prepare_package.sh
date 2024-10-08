#!/bin/bash

. ../scripts/funcations.sh

### 基础部分 ###
# 使用 O2 级别的优化
sed -i 's/Os/O2/g' include/target.mk
# 默认开启 Irqbalance
sed -i "s/enabled '0'/enabled '1'/g" feeds/packages/utils/irqbalance/files/irqbalance.config

### Prepare package
# Delete default menu setting
sed -i '/services/d' package/lean/default-settings/files/zzz-default-settings
# Passwall
cp -rf ../passwall_luci/luci-app-passwall ./package/luci-app-passwall
cp -rf ../passwall_pkg ./package/passwall-pkg
rm -rf ./package/passwall-pkg/v2ray-geodata
# Passwall 白名单
echo '
teamviewer.com
epicgames.com
dangdang.com
account.synology.com
ddns.synology.com
checkip.synology.com
checkip.dyndns.org
checkipv6.synology.com
ntp.aliyun.com
cn.ntp.org.cn
ntp.ntsc.ac.cn
' >>./package/luci-app-passwall/root/usr/share/passwall/rules/direct_host
# Opencalsh
cp -rf ../openclash ./package/luci-app-openclash
# Filebrowser
cp -rf ../lienol_pkg/luci-app-filebrowser ./package/luci-app-filebrowser
pushd package/luci-app-filebrowser
move_2_services nas
popd
# Mosdns
rm -rf ./feeds/packages/net/v2ray-geodata
rm -rf ./feeds/packages/net/mosdns
cp -rf ../mosdns ./package/luci-app-mosdns
# Vsftpd
pushd package/feeds/luci/luci-app-vsftpd
move_2_services nas
popd
# Cpufreq
sed -i 's,\"system\",\"services\",g' package/feeds/luci/luci-app-cpufreq/luasrc/controller/cpufreq.lua
# Rclone
sed -i -e 's,\"NAS\",\"Services\",g' -e 's,\"nas\",\"services\",g' package/feeds/luci/luci-app-rclone/luasrc/controller/rclone.lua
# Dockerman
pushd package/feeds/luci/luci-app-dockerman
docker_2_services
popd
# Nlbw
sed -i -e 's|admin\",|& \"network\",|g' -e 's,admin/,&network/,g' package/feeds/luci/luci-app-nlbwmon/luasrc/controller/nlbw.lua
sed -i 's,admin/,&network/,g' package/feeds/luci/luci-app-nlbwmon/luasrc/model/cbi/nlbw/config.lua
sed -i 's,admin/,&network/,g' package/feeds/luci/luci-app-nlbwmon/luasrc/view/nlbw/backup.htm
sed -i 's,admin/,&network/,g' package/feeds/luci/luci-app-nlbwmon/luasrc/view/nlbw/display.htm
# V2raya
git clone -b 18.06 --depth 1 https://github.com/zxlhhyccc/luci-app-v2raya.git package/new/luci-app-v2raya
cp -rf ../immortalwrt_pkg/net/v2raya ./feeds/packages/net/v2raya
ln -sf ../../../feeds/packages/net/v2raya ./package/feeds/packages/v2raya
# Verysync
pushd package/feeds/luci/luci-app-verysync
move_2_services nas
popd
# Curl 8.6.0 passwall 冲突降级
sed -i "s,PKG_VERSION:=.*,PKG_VERSION:=8\.5\.0," ./feeds/packages/net/curl/Makefile
sed -i "s,PKG_HASH:=.*,PKG_HASH:=ce4b6a6655431147624aaf582632a36fe1ade262d5fab385c60f78942dd8d87b," ./feeds/packages/net/curl/Makefile

# fix xfsprogs
sed -i 's,TARGET_CFLAGS += -DHAVE_MAP_SYNC,& -D_LARGEFILE64_SOURCE,' feeds/packages/utils/xfsprogs/Makefile

# 预配置一些插件
cp -rf ../patch/files ./files
sed -i 's,/bin/ash,/bin/bash,' ./package/base-files/files/etc/passwd && sed -i 's,/bin/ash,/bin/bash,' ./package/base-files/files/usr/libexec/login.sh
mkdir -p files/etc/openclash/core
pushd files/etc/openclash/core
clash_version="$(curl -fsSL https://github.com/vernesong/OpenClash/raw/core/master/core_version | sed -n '2p')"
wget https://github.com/vernesong/OpenClash/raw/core/master/premium/clash-linux-arm64-${clash_version}.gz -O clash_tun.gz && gzip -d clash_tun.gz
wget https://github.com/vernesong/OpenClash/raw/core/master/meta/clash-linux-arm64.tar.gz -O clash_meta.tar.gz && tar -zxvf clash_meta.tar.gz && mv clash clash_meta
wget https://github.com/vernesong/OpenClash/raw/core/master/dev/clash-linux-arm64.tar.gz -O clash.tar.gz && tar -zxvf clash.tar.gz
chmod +x ./clash*
find ./ -name "*.tar.gz" | xargs rm -f
popd

chmod -R 755 ./
find ./ -name *.orig | xargs rm -f
find ./ -name *.rej | xargs rm -f

exit 0
