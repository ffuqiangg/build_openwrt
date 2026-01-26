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
. set_env "build_date" "${build_date}"


p "克隆 lede 到 ${workdir}/openwrt"
. set_env "wrtdir" "${workdir}/openwrt"
umask 0022
clone master ${lede_repo} ${wrtdir}
pushd ${wrtdir}
git config core.filemode false # 忽略权限变更
popd

p "获取 distrib_revision"
distrib_revision=$(grep 'DISTRIB_REVISION=' ${wrtdir}/package/lean/default-settings/files/zzz-default-settings | sed -E "s/.*'(.+)'.*/\1/")
. set_env "distrib_revision" "${distrib_revision}"

p "下载其它仓库"
. set_env "otherdir" "${ffdir}/other"
clone master ${immortalwrt_luci_repo} ${otherdir}/imm_luci_ma &
clone master ${immortalwrt_pkg_repo} ${otherdir}/imm_pkg_ma &
clone master ${dockerman_repo} ${otherdir}/dockerman &
clone main ${momo_repo} ${otherdir}/openwrt-momo &
clone master ${v2ray_geodata_repo} ${otherdir}/v2ray_geodata &
clone master ${openwrt_add_repo} ${otherdir}/openwrt-add &
clone main ${sbwml_pkgs_repo} ${otherdir}/sbwml_pkg &
wait && sync

p "一些调整"
p "修改默认 IP ( 192.168.1.99 )"
    sed -i "/lan) ipad=\${ipaddr:-/s/\${ipaddr:-\"[^\"]*\"}/\${ipaddr:-\"192.168.1.99\"}/" ${wrtdir}/package/base-files/*/bin/config_generate
p "默认禁用 WIFI"
    sed -i '/wireless/d' ${wrtdir}/package/lean/default-settings/files/zzz-default-settings
    sed -Ei "s/(disabled=)0/\11/" ${wrtdir}/package/kernel/mac80211/files/lib/wifi/mac80211.sh
p "调整内核版本为 5.15"
    sed -i 's/KERNEL_PATCHVER:=.*/KERNEL_PATCHVER:=5.15/' ${wrtdir}/target/linux/amlogic/Makefile
# p "针对 N1 的编译优化"
#     sed -i '/aarch64)/{n;s/CPU_TYPE.*/CPU_TYPE = cortex-a53/;}' ${wrtdir}/include/target.mk 
#     sed -i '/CPU_TYPE = cortex-a53/a\    CPU_CFLAGS = -O2 -pipe -fpredictive-commoning -ftree-partial-pre -floop-interchange -fschedule-insns -fsched-pressure -ftree-vectorize -fvect-cost-model=cheap -mno-outline-atomics -fweb -frename-registers -fno-plt' ${wrtdir}/include/target.mk
#     sed -i '/CPU_TYPE = cortex-a53/{n;n;s/CPU_CFLAGS_generic.*/CPU_CFLAGS_generic = -mcpu=cortex-a53+crypto+crc/;}' ${wrtdir}/include/target.mk
#     sed -i '/CPU_TYPE = cortex-a53/{n;n;n;s/$/+crypto+crc/;}' ${wrtdir}/include/target.mk


p ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"


p "进入编译目录 ${wrtdir}"
cd ${wrtdir}

# 这里一定要用绝对路径；将包含自定义订阅源的行移动到标准订阅源上方，即可覆盖标准订阅源
# sed -i "1isrc-link add ${wrtdir}/package/add" feeds.conf.default 
    

p "更新 Feeds"
./scripts/feeds update -a
./scripts/feeds install -a


p "应用自定义修改"
mkdir -p ./package/add
# p "使用 O2 级别的优化"
# sed -i 's/Os/O2/g' ./include/target.mk
p "启用 bash"
sed -i 's,/bin/ash,/bin/bash,' package/base-files/files/{etc/passwd,usr/libexec/login.sh}
p "确保加载 /etc/shinit"
echo -e "\n[ -f /etc/shinit ] && . /etc/shinit" >> ./package/base-files/files/etc/profile
p "修复 Rust CI 下载限制"
sed -i '/--set=llvm.download-ci-llvm/s/true/false/' ./feeds/packages/lang/rust/Makefile


p "LuCI 自定义 nft 规则页面"
patch -p1 < ${ffdir}/patch/firewall/100-openwrt-firewall4-add-custom-nft-command-support.patch
pushd feeds/luci
patch -p1 <${ffdir}/patch/firewall/04-luci-add-firewall4-nft-rules-file.patch
popd


p "调整刷机脚本"
patch -p1 < ${ffdir}/patch/custom_install/lede/custom_target_amlogic_scripts.patch
mkdir -p ./target/linux/amlogic/mesongx/base-files/usr
mv -f ./target/linux/amlogic/mesongx/base-files/root ./target/linux/amlogic/mesongx/base-files/usr/sbin

p "调整 default-settings"
sed -i '/services/d;/exit/d' ./package/lean/default-settings/files/zzz-default-settings
cat <<'EOF' >> package/lean/default-settings/files/zzz-default-settings
sed -i '/BUILD_DATE/d' /etc/openwrt_release
echo "BUILD_DATE='${build_date}'" >> /etc/openwrt_release

exit 0
EOF


p "预编译 node"
rm -rf ./feeds/packages/lang/node/*
wget https://raw.githubusercontent.com/sbwml/feeds_packages_lang_node-prebuilt/packages-24.10/Makefile -O ./feeds/packages/lang/node/Makefile
p "更换 golang 版本"
rm -rf ./feeds/packages/lang/golang
git clone --depth 1 https://github.com/sbwml/packages_lang_golang -b 26.x ./feeds/packages/lang/golang

p "一些补充翻译"
echo '
msgid "Custom rules allow you to execute arbitrary nft commands which are not otherwise covered by the firewall framework. The rules are executed after each firewall restart, right after the default ruleset has been loaded."
msgstr "自定义规则允许您执行不属于防火墙框架的任意 nft 命令。每次重启防火墙时，这些命令在默认的规则运行后立即执行。"
' >> ./package/lean/default-settings/po/zh-cn/default.po

p "mount cgroupv2"
pushd feeds/packages
patch -p1 < ${ffdir}/patch/cgroupfs-mount/0001-fix-cgroupfs-mount.patch
popd
mkdir -p ./feeds/packages/utils/cgroupfs-mount/patches
cp -rf ${ffdir}/patch/cgroupfs-mount/900-mount-cgroup-v2-hierarchy-to-sys-fs-cgroup-cgroup2.patch ./feeds/packages/utils/cgroupfs-mount/patches/
cp -rf ${ffdir}/patch/cgroupfs-mount/901-fix-cgroupfs-umount.patch ./feeds/packages/utils/cgroupfs-mount/patches/
cp -rf ${ffdir}/patch/cgroupfs-mount/902-mount-sys-fs-cgroup-systemd-for-docker-systemd-suppo.patch ./feeds/packages/utils/cgroupfs-mount/patches/

p "替换 sing-box"
rm -rf ./feeds/packages/net/sing-box
cp -rf ${otherdir}/imm_pkg_ma/net/sing-box ./feeds/packages/net/sing-box
p "v2rayA"
rm -rf ./feeds/luci/applications/luci-app-v2raya ./feeds/packages/net/v2raya
cp -rf ${otherdir}/imm_luci_ma/applications/luci-app-v2raya ./feeds/luci/applications/luci-app-v2raya
cp -rf ${otherdir}/imm_pkg_ma/net/v2raya ./feeds/packages/net/v2raya

p "MosDNS"
rm -rf ./feeds/luci/applications/luci-app-mosdns ./feeds/packages/utils/v2dat
rm -rf ./feeds/packages/net/{mosdns,v2ray-geodata}
cp -rf ${otherdir}/openwrt-add/luci-app-mosdns ./package/add/luci-app-mosdns
cp -rf ${otherdir}/v2ray_geodata ./package/add/v2ray-geodata

p "Passwall"
rm -rf ./feeds/luci/applications/luci-app-passwall
rm -rf ./feeds/packages/net/{chinadns-ng,dns2socks,dns2tcp,geoview,hysteria,microsocks,pdnsd-alt,tcping,trojan,xray-core}
cp -rf ${otherdir}/openwrt-add/openwrt_helloworld ./package/add/
rm -rf ./package/add/openwrt_helloworld/v2ray-geodata
sed -i '/select PACKAGE_geoview/{n;s/default n/default y/;}' ./package/add/openwrt_helloworld/luci-app-passwall/Makefile
sed -i '/#dde2ff/d;/#2c323c/d' ./package/add/openwrt_helloworld/luci-app-passwall/luasrc/view/passwall/global/status.htm

p "OpenWrt-nikki"
rm -rf ./feeds/luci/applications/luci-app-nikki ./feeds/packages/net/nikki
cp -rf ${otherdir}/openwrt-add/OpenWrt-mihomo ./package/add/luci-app-nikki
p "OpenWrt-momo"
cp -rf ${otherdir}/openwrt-momo ./package/add/luci-app-momo

p "Rclone"
sed -i 's,NAS,Services,g;s,nas,services,g' ./feeds/luci/applications/luci-app-rclone/luasrc/controller/rclone.lua
p "Nlbw 带宽监控"
sed -i 's,services,network,g' ./feeds/luci/applications/luci-app-nlbwmon/root/usr/share/luci/menu.d/luci-app-nlbwmon.json
sed -i 's,services,network,g' ./feeds/luci/applications/luci-app-nlbwmon/htdocs/luci-static/resources/view/nlbw/config.js
p "终端 TTYD"
sed -i 's,services,system,g' ./feeds/luci/applications/luci-app-ttyd/root/usr/share/luci/menu.d/luci-app-ttyd.json

p "Docker 容器"
rm -rf ./feeds/luci/applications/luci-app-dockerman
cp -rf ${otherdir}/dockerman/applications/luci-app-dockerman ./package/add/luci-app-dockerman
sed -i '/auto_start/d' ./package/add/luci-app-dockerman/root/etc/uci-defaults/luci-app-dockerman
sed -i '/^start_service/a\\t[ "$(uci -q get dockerd.globals.auto_start)" -eq "0" ] && return 1\n' ./feeds/packages/utils/dockerd/files/dockerd.init
pushd package/add//luci-app-dockerman
bash ${ffdir}/prepare/docker.sh
popd

p "Filebrowser 文件管理器"
rm -rf ./feeds/luci/applications/luci-app-filebrowser ./feeds/packages/utils/filebrowser
cp -rf ${otherdir}/sbwml_pkg/{luci-app-filebrowser-go,filebrowser} ./package/add/
p "Daed"
rm -rf ./feeds/packages/net/daed ./feeds/luci/applications/luci-app-daed
cp -rf ${otherdir}/openwrt-add/luci-app-daed ./package/add/luci-app-daed
cp -rf ${otherdir}/imm_pkg_ma/libs/libcron ./package/add/libcron


p "复制自定义文件目录"
cp -rf ${ffdir}/files/init ./files
mkdir -p ./files/etc/uci-defaults && cp -f ${ffdir}/prepare/lede/zzz-default-settings ./files/etc/uci-defaults/
echo -e "\n\033[34mLEDE\033[0m ${distrib_revision} | ${build_date//./-}\n" > ./files/etc/banner


p "清理临时文件"
rm -rf ${otherdir}
find ./ -name *.orig | xargs rm -f
find ./ -name *.rej | xargs rm -f

p "容器内脚本结束"
