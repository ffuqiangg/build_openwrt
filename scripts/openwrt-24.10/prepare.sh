# 注意：此脚本在容器内运行
#
# p: 打印日志
# clone: git浅克隆，参数1: 分支名 参数2: 仓库地址 参数3: 目标目录
# set_env: 设置环境变量，参数1: 变量名 参数2: 变量值
#
# 运行到这个脚本时依赖已安装；${workdir} 和 ${ffdir} 已设置
#

p "配置 git"
git config --global user.name "github-actions[bot]"
git config --global user.email "41898282+github-actions[bot]@users.noreply.github.com"
git config --global core.abbrev auto


p "修改时区为上海"
sudo ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

p "获取基础变量"
build_date=$(date +%Y.%m.%d)
latest_release=$(curl -s https://github.com/openwrt/openwrt/tags | grep -Po "v[0-9\.]+-*r*c*[0-9]*(?=\.tar\.gz)" | sed -n '/24.10/p' | sed -n 1p | sed 's/v//g')
. set_env "build_date" "${build_date}"
. set_env "latest_release" "${latest_release}"


p "克隆 openwrt 到 ${workdir}/openwrt"
. set_env "wrtdir" "${workdir}/openwrt"
umask 0022
clone "v${latest_release}" ${openwrt_repo} ${wrtdir}
pushd ${wrtdir}
git config core.filemode false # 忽略权限变更
popd

p "获取内核版本"
current_version=$(sed -n 's/^KERNEL_PATCHVER:=//p' ${wrtdir}/target/linux/armsr/Makefile)
kernel_version=$(sed -n '/LINUX_KERNEL_HASH/p' ${wrtdir}/include/kernel-${current_version} | awk -F '[ -]' '{print $2}')
. set_env "current_version" "${current_version}"
. set_env "kernel_version" "${kernel_version}"

p "下载其它仓库"
. set_env "otherdir" "${ffdir}/other"
clone master ${immortalwrt_luci_repo} ${otherdir}/imm_luci_ma &
clone master ${immortalwrt_pkg_repo} ${otherdir}/imm_pkg_ma &
clone master ${dockerman_repo} ${otherdir}/dockerman &
clone master ${v2ray_geodata_repo} ${otherdir}/v2ray_geodata &
clone openwrt-24.10 ${autocore_arm_repo} ${otherdir}/autocore &
clone main ${sbwml_pkgs_repo} ${otherdir}/sbwml_pkgs &
clone master ${openwrt_add_repo} ${otherdir}/openwrt-add &
clone main ${momo_repo} ${otherdir}/openwrt-momo &
clone main ${amlogic_repo} ${otherdir}/amlogic &
wait && sync

p "一些调整"
p "设置默认密码为 password"
    sed -i 's/root:::0:99999:7:::/root:$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.::0:99999:7:::/g' ${wrtdir}/package/base-files/files/etc/shadow
# p "修改默认 IP 为 192.168.1.99"
#     sed -i 's/192.168.1.1/192.168.1.99/g' ${wrtdir}/package/base-files/files/bin/config_generate


p ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"


p "进入编译目录 ${wrtdir}"
cd ${wrtdir}

p "更新 Feeds"
./scripts/feeds update -a
./scripts/feeds install -a


p "卸载无法编译的包"
./scripts/feeds uninstall exim onionshare-cli python-zope-event python-zope-interface python-gevent python-twisted || true

p "应用自定义修改"
mkdir -p ./package/add
p "使用 O2 级别的优化"
sed -i 's/Os/O2/g' ./include/target.mk
p "vermagic"
sed -i '/CONFIG_BUILDBOT/d' ./include/feeds.mk
sed -i 's/;)\s*\\/; \\/' ./include/feeds.mk
p "确保加载 /etc/shinit"
echo -e "\n[ -f /etc/shinit ] && . /etc/shinit" >> ./package/base-files/files/etc/profile
p "修复 Rust CI 下载限制"
sed -i '/--set=llvm.download-ci-llvm/s/true/false/' ./feeds/packages/lang/rust/Makefile


p "LuCI 自定义 nft 规则页面"
patch -p1 < ${ffdir}/patch/firewall/100-openwrt-firewall4-add-custom-nft-command-support.patch
pushd feeds/luci
patch -p1 <${ffdir}/patch/firewall/04-luci-add-firewall4-nft-rules-file.patch
popd


p "预编译 node"
rm -rf ./feeds/packages/lang/node/*
wget https://raw.githubusercontent.com/sbwml/feeds_packages_lang_node-prebuilt/packages-24.10/Makefile -O ./feeds/packages/lang/node/Makefile
p "更换 golang 版本"
rm -rf ./feeds/packages/lang/golang
git clone --depth 1 https://github.com/sbwml/packages_lang_golang -b 26.x ./feeds/packages/lang/golang

p "一些补充翻译"
cp -rf ${ffdir}/patch/trans-zh ./package/add/

p "mount cgroupv2"
pushd feeds/packages
patch -p1 < ${ffdir}/patch/cgroupfs/0001-fix-cgroupfs-mount.patch
popd
mkdir -p ./feeds/packages/utils/cgroupfs-mount/patches
cp -rf ${ffdir}/patch/cgroupfs/900-mount-cgroup-v2-hierarchy-to-sys-fs-cgroup-cgroup2.patch ./feeds/packages/utils/cgroupfs-mount/patches/
cp -rf ${ffdir}/patch/cgroupfs/901-fix-cgroupfs-umount.patch ./feeds/packages/utils/cgroupfs-mount/patches/
cp -rf ${ffdir}/patch/cgroupfs/902-mount-sys-fs-cgroup-systemd-for-docker-systemd-suppo.patch ./feeds/packages/utils/cgroupfs-mount/patches/

p "CPUlimit 占用限制"
cp -rf ${otherdir}/imm_luci_ma/applications/luci-app-cpulimit ./package/add/luci-app-cpulimit
sed -i 's|\.\./\.\.|$(TOPDIR)/feeds/luci|g' ./package/add/luci-app-cpulimit/Makefile
cp -rf ${otherdir}/imm_pkg_ma/utils/cpulimit ./package/add/cpulimit
p "IP/MAC 绑定"
cp -rf ${otherdir}/imm_luci_ma/applications/luci-app-arpbind ./package/add/luci-app-arpbind
sed -i 's|\.\./\.\.|$(TOPDIR)/feeds/luci|g' ./package/add/luci-app-arpbind/Makefile
p "DDNS scripts aliyun"
cp -rf ${otherdir}/sbwml_pkgs/ddns-scripts-aliyun ./package/add/
p "Coremark"
rm -rf ./feeds/packages/utils/coremark
cp -rf ${otherdir}/sbwml_pkgs/coremark ./feeds/packages/utils/coremark
p "Autocore"
cp -rf ${otherdir}/autocore ./package/add/autocore
sed -i 's/$(uname -m)/ARMv8 Processor/' ./package/add/autocore/files/generic/cpuinfo

p "替换 sing-box"
rm -rf ./feeds/packages/net/sing-box
cp -rf ${otherdir}/imm_pkg_ma/net/sing-box ./feeds/packages/net/sing-box
p "v2rayA"
rm -rf ./feeds/luci/applications/luci-app-v2raya ./feeds/packages/net/v2raya
cp -rf ${otherdir}/imm_luci_ma/applications/luci-app-v2raya ./feeds/luci/applications/luci-app-v2raya
cp -rf ${otherdir}/imm_pkg_ma/net/v2raya ./feeds/packages/net/v2raya

p "MosDNS"
rm -rf ./feeds/packages/net/{v2ray-geodata,mosdns}
cp -rf ${otherdir}/openwrt-add/luci-app-mosdns ./package/add/luci-app-mosdns
cp -rf ${otherdir}/v2ray_geodata ./package/add/v2ray-geodata

p "Passwall"
rm -rf ./feeds/packages/net/{xray-core,microsocks}
cp -rf ${otherdir}/openwrt-add/openwrt_helloworld ./package/add/
rm -rf ./package/add/openwrt_helloworld/v2ray-geodata
sed -i '/select PACKAGE_geoview/{n;s/default n/default y/;}' package/add/openwrt_helloworld/luci-app-passwall/Makefile
sed -i '/#dde2ff/d;/#2c323c/d' package/add/openwrt_helloworld/luci-app-passwall/luasrc/view/passwall/global/status.htm

p "OpenWrt-nikki"
cp -rf ${otherdir}/openwrt-add/OpenWrt-mihomo ./package/add/luci-app-nikki
p "OpenWrt-momo"
cp -rf ${otherdir}/openwrt-momo ./package/add/luci-app-momo

p "Daed"
cp -rf ${otherdir}/openwrt-add/luci-app-daed ./package/add/
cp -rf ${otherdir}/imm_pkg_ma/libs/libcron ./feeds/packages/libs/libcron
p "HomeProxy"
cp -rf ${otherdir}/openwrt-add/homeproxy ./package/add/luci-app-homeproxy

p "Docker 容器"
rm -rf ./feeds/luci/applications/luci-app-dockerman
cp -rf ${otherdir}/dockerman/applications/luci-app-dockerman ./package/add/luci-app-dockerman
sed -i '/auto_start/d' package/add/luci-app-dockerman/root/etc/uci-defaults/luci-app-dockerman
sed -i '/^start_service/a\\t[ "$(uci -q get dockerd.globals.auto_start)" -eq "0" ] && return 1\n' feeds/packages/utils/dockerd/files/dockerd.init
pushd package/add/luci-app-dockerman
bash ${ffdir}/prepare/docker.sh
popd

p "Zerotier"
rm -rf ./feeds/luci/applications/luci-app-zerotier ./feeds/packages/net/zerotier
cp -rf ${otherdir}/imm_luci_ma/applications/luci-app-zerotier ./feeds/luci/applications/luci-app-zerotier
cp -rf ${otherdir}/imm_pkg_ma/net/zerotier ./feeds/packages/net/zerotier
p "Filebrowser 文件管理器"
cp -rf ${otherdir}/sbwml_pkgs/{luci-app-filebrowser-go,filebrowser} ./package/add/
p "KMS 服务器"
cp -rf ${otherdir}/sbwml_pkgs/{luci-app-vlmcsd,vlmcsd} ./package/add/
p "FTP 服务器"
rm -rf ./feeds/packages/net/vsftpd
cp -rf ${otherdir}/sbwml_pkgs/luci-app-vsftpd ./package/add/luci-app-vsftpd
cp -rf ${otherdir}/imm_pkg_ma/net/vsftpd ./feeds/packages/net/vsftpd

p "Nlbw 带宽监控"
sed -i 's,services,network,g' ./package/feeds/luci/luci-app-nlbwmon/root/usr/share/luci/menu.d/luci-app-nlbwmon.json
sed -i 's,services,network,g' ./package/feeds/luci/luci-app-nlbwmon/htdocs/luci-static/resources/view/nlbw/config.js
p "终端 TTYD"
sed -i 's,services,system,g' ./package/feeds/luci/luci-app-ttyd/root/usr/share/luci/menu.d/luci-app-ttyd.json

p "晶晨宝盒"
cp -rf ${otherdir}/amlogic/luci-app-amlogic ./package/add/

p "处理菜单"
pushd ./feeds/luci
bash ${ffdir}/prepare/menu.sh
popd


p "Vermagic 内核兼容模块"
wget https://downloads.openwrt.org/releases/${latest_release}/targets/armsr/armv8/profiles.json
jq -r '.linux_kernel.vermagic' profiles.json > .vermagic
cat .vermagic
sed -i -e 's/^\(.\).*vermagic$/\1cp $(TOPDIR)\/.vermagic $(LINUX_DIR)\/.vermagic/' include/kernel-defaults.mk
rm -f profiles.json


p "复制自定义文件目录"
cp -rf ${ffdir}/files ./files
mkdir -p ./files/etc/uci-defaults && cp -f ${ffdir}/scripts/openwrt-24.10/zzz-default-settings ./files/etc/uci-defaults/
echo -e "\n\033[34mOpenWrt\033[0m ${latest_release} | ${build_date//./-}\n" > ./files/etc/banner


p "清理临时文件"
rm -rf ${otherdir}
find ./ -name *.orig | xargs rm -f
find ./ -name *.rej | xargs rm -f

p "容器内脚本结束"
