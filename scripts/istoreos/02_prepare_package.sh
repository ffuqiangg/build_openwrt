#!/bin/bash

. ../scripts/funcations.sh

### 基础部分 ###
# 使用 O2 级别的优化
sed -i 's/Os/O2/g' include/target.mk
# 更新 Feeds
./scripts/feeds update -a
./scripts/feeds install -a
# 默认开启 Irqbalance
sed -i "s/enabled '0'/enabled '1'/g" feeds/packages/utils/irqbalance/files/irqbalance.config

### FIREWALL ###
# custom nft command
patch -p1 < ../patch/firewall/100-openwrt-firewall4-add-custom-nft-command-support.patch
# patch LuCI 以支持自定义 nft 规则
pushd feeds/luci
patch -p1 < ../../../patch/firewall/04-luci-add-firewall4-nft-rules-file.patch
popd

### 替换准备 ###
cp -rf ../openwrt-apps ./package/new
rm -rf feeds/packages/net/{xray-core,v2ray-core,v2ray-geodata,frp,shadowsocks-libev,v2raya}
rm -rf feeds/luci/applications/{luci-app-frps,luci-app-frpc,luci-app-v2raya,luci-app-dockerman}
rm -rf feeds/packages/utils/coremark

### 获取额外的 LuCI 应用和依赖 ###
# 添加 default settings
cp -f ../patch/default-settings/istoreos/99-default-settings ./package/istoreos-files/files/etc/uci-defaults/
# Golang
rm -rf ./feeds/packages/lang/golang
cp -rf ../openwrt_pkg_ma/lang/golang ./feeds/packages/lang/golang
# 预编译 node
rm -rf feeds/packages/lang/node
cp -rf ../node feeds/packages/lang/node
# Autocore
rm -rf ./package/new/autocore-arm
git clone --depth 1 -b openwrt-22.03 https://github.com/sbwml/autocore-arm.git ./package/new/autocore-arm
# DAED
echo '

define KernelPackage/xdp-sockets-diag
  SUBMENU:=$(NETWORK_SUPPORT_MENU)
  TITLE:=PF_XDP sockets monitoring interface support for ss utility
  KCONFIG:= \
	CONFIG_XDP_SOCKETS=y \
	CONFIG_XDP_SOCKETS_DIAG
  FILES:=$(LINUX_DIR)/net/xdp/xsk_diag.ko
  AUTOLOAD:=$(call AutoLoad,31,xsk_diag)
endef

define KernelPackage/xdp-sockets-diag/description
 Support for PF_XDP sockets monitoring interface used by the ss tool
endef

$(eval $(call KernelPackage,xdp-sockets-diag))' >> ./package/kernel/linux/modules/netsupport.mk
# Docker 容器
cp -rf ../dockerman/applications/luci-app-dockerman feeds/luci/applications/luci-app-dockerman
sed -i '/auto_start/d' feeds/luci/applications/luci-app-dockerman/root/etc/uci-defaults/luci-app-dockerman
pushd package/feeds/luci/luci-app-dockerman
docker_2_services
popd
# Nlbw 带宽监控
sed -i 's,services,network,g' feeds/luci/applications/luci-app-nlbwmon/root/usr/share/luci/menu.d/luci-app-nlbwmon.json
# 终端 TTYD
sed -i 's,services,system,g' feeds/luci/applications/luci-app-ttyd/root/usr/share/luci/menu.d/luci-app-ttyd.json

# 预配置一些插件
mkdir -p files
sed -i 's,/bin/ash,/bin/bash,' ./package/base-files/files/etc/passwd && sed -i 's,/bin/ash,/bin/bash,' ./package/base-files/files/usr/libexec/login.sh
cp -rf ../files/{etc,root,cpufreq/*} files/
clash_version="$(curl -fsSL https://github.com/vernesong/OpenClash/raw/core/master/core_version | sed -n '2p')"
wget -qO- https://github.com/vernesong/OpenClash/raw/core/master/premium/clash-linux-arm64-${clash_version}.gz | gunzip -c > files/etc/openclash/core/clash_tun
wget -qO- https://github.com/vernesong/OpenClash/raw/core/master/meta/clash-linux-arm64.tar.gz | tar xOvz > files/etc/openclash/core/clash_meta
wget -qO- https://github.com/vernesong/OpenClash/raw/core/master/dev/clash-linux-arm64.tar.gz | tar xOvz > files/etc/openclash/core/clash
chmod +x files/etc/openclash/core/clash*

find ./ -name *.orig | xargs rm -f
find ./ -name *.rej | xargs rm -f

exit 0
