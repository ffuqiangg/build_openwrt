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
latest_release=$(curl -s https://github.com/openwrt/openwrt/tags | grep -Po "v[0-9\.]+-*r*c*[0-9]*(?=\.tar\.gz)" | sed -n '/25.12/p' | sed -n 1p | sed 's/v//g')
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
kernel_version=$(sed -n "s/^LINUX_VERSION-${current_version} = //p" ${wrtdir}/target/linux/generic/kernel-${current_version})
. set_env "current_version" "${current_version}"
. set_env "kernel_version" "${current_version}${kernel_version}"

p "下载其它仓库"
. set_env "otherdir" "${workdir}/other"
clone master ${immortalwrt_luci_repo} ${otherdir}/imm_luci_ma &
clone master ${immortalwrt_pkg_repo} ${otherdir}/imm_pkg_ma &
clone master ${v2ray_geodata_repo} ${otherdir}/v2ray_geodata &
clone main ${podman_repo} ${otherdir}/podman &
clone master ${openwrt_add_repo} ${otherdir}/openwrt-add &
clone main ${amlogic_repo} ${otherdir}/amlogic &
clone 25.12 ${yaof_repo} ${otherdir}/yaof &
wait && sync

p "一些调整"
# p "修改 IP ( 192.168.1.99 )"
#     sed -i 's/192.168.1.1/192.168.1.99/g' ${wrtdir}/package/base-files/files/bin/config_generate
p "编译优化"
    sed -i 's/Os/O2/g' ${wrtdir}/include/target.mk
    sed -i 's/-mcpu=cortex-a53/&+crypto+crc -fpredictive-commoning -ftree-partial-pre -floop-interchange -fschedule-insns -fsched-pressure -ftree-vectorize -fvect-cost-model=cheap -mno-outline-atomics -fweb -frename-registers -fno-plt/' ${wrtdir}/include/target.mk
p "删除 apk 提示"
    rm -f ${wrtdir}/package/base-files/files/etc/profile.d/apk-cheatsheet.sh


p ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"


p "进入编译目录 ${wrtdir}"
cd ${wrtdir}

p "切换 github 源"
sed -e 's,git.openwrt.org/feed/packages,github.com/openwrt/packages,g' \
    -e 's,git.openwrt.org/project/luci,github.com/openwrt/luci,g' \
    -e 's,git.openwrt.org/feed/routing,github.com/openwrt/routing,g' \
    -e 's,git.openwrt.org/feed/telephony,github.com/openwrt/telephony,g' \
    -i.bak ./feeds.conf.default

p "更新 Feeds"
./scripts/feeds update -f -a
./scripts/feeds install -f -a


p "卸载无法编译的包"
./scripts/feeds uninstall onionshare-cli luci-app-mjpg-streamer || true
p "luci-app-attendedsysupgrade"
sed -i '/luci-app-attendedsysupgrade/d' ./feeds/luci/collections/luci-nginx/Makefile

p "应用自定义修改"
mkdir -p ./package/add
p "vermagic"
sed -i '/CONFIG_BUILDBOT/d' ./include/feeds.mk
sed -i 's/;)\s*\\/; \\/' ./include/feeds.mk


p "Nginx"
sed -i "s/large_client_header_buffers 2 1k/large_client_header_buffers 4 32k/g" ./feeds/packages/net/nginx-util/files/uci.conf.template
sed -i "s/client_max_body_size 128M/client_max_body_size 2048M/g" ./feeds/packages/net/nginx-util/files/uci.conf.template
sed -i '/client_max_body_size/a\\tclient_body_buffer_size 8192M;' ./feeds/packages/net/nginx-util/files/uci.conf.template
sed -i '/client_max_body_size/a\\tserver_names_hash_bucket_size 128;' ./feeds/packages/net/nginx-util/files/uci.conf.template
sed -i '/ubus_parallel_req/a\        ubus_script_timeout 600;' ./feeds/packages/net/nginx/files-luci-support/60_nginx-luci-support
sed -ri "/luci-webui.socket/i\ \t\tuwsgi_send_timeout 600\;\n\t\tuwsgi_connect_timeout 600\;\n\t\tuwsgi_read_timeout 600\;" ./feeds/packages/net/nginx/files-luci-support/luci.locations
sed -ri "/luci-cgi_io.socket/i\ \t\tuwsgi_send_timeout 600\;\n\t\tuwsgi_connect_timeout 600\;\n\t\tuwsgi_read_timeout 600\;" ./feeds/packages/net/nginx/files-luci-support/luci.locations
p "uwsgi"
sed -i 's,procd_set_param stderr 1,procd_set_param stderr 0,g' ./feeds/packages/net/uwsgi/files/uwsgi.init
sed -i 's,buffer-size = 10000,buffer-size = 131072,g' ./feeds/packages/net/uwsgi/files-luci-support/luci-webui.ini
sed -i 's,logger = luci,#logger = luci,g' ./feeds/packages/net/uwsgi/files-luci-support/luci-webui.ini
sed -i '$a cgi-timeout = 600' ./feeds/packages/net/uwsgi/files-luci-support/luci-*.ini
sed -i 's/threads = 1/threads = 2/g' ./feeds/packages/net/uwsgi/files-luci-support/luci-webui.ini
sed -i 's/processes = 3/processes = 4/g' ./feeds/packages/net/uwsgi/files-luci-support/luci-webui.ini
sed -i 's/cheaper = 1/cheaper = 2/g' ./feeds/packages/net/uwsgi/files-luci-support/luci-webui.ini
# rpcd
sed -i 's/option timeout 30/option timeout 60/g' ./package/system/rpcd/files/rpcd.config
sed -i 's#20) \* 1000#60) \* 1000#g' ./feeds/luci/modules/luci-base/htdocs/luci-static/resources/rpc.js

p "配置优化"
echo "
# 调优部分

# 确保缓冲区足够用，7.5MB的udp和6MB的tcp对于路由器足够大了
net.core.rmem_max = 7500000
net.core.wmem_max = 7500000
net.ipv4.tcp_rmem = 4096 131072 6291456
net.ipv4.tcp_wmem = 4096 16384 6291456

# 开启 TCP 连接复用 (主要用于出站连接，对作为客户端时有效)
net.ipv4.tcp_tw_reuse = 1

# 开启 TCP Fast Open
# 1: 仅作为客户端开启
# 2: 仅作为服务端开启
# 3: 两端都开启
# 应该设置为1, 3在国内会导致海外包被丢弃
net.ipv4.tcp_fastopen = 1

# 开启 MPTCP，默认不打开
# net.mptcp.mptcp_enabled = 1

# 关闭 MTU 探测，国内开启会有反效果
net.ipv4.tcp_mtu_probing = 0

# 默认是 1 (1/2 是数据, 1/2 是元数据)。
# 改为 -2 (3/4 是数据, 1/4 是元数据)。
# 在不增加 total 内存消耗的情况下，TCP 窗口变大 50%
net.ipv4.tcp_adv_win_scale = -2

# Cloudflare 设为 6MB (6291456)。
# tcp_rmem max 只有 6MB，这里设为 5MB 即可。
# 逻辑：当接收队列中的数据小于这个值时，如果不幸发生内存满，允许尝试整理(collapse)以挽救数据。
# 超过这个值，直接丢包，避免 CPU 飙升导致的高延迟。
net.ipv4.tcp_collapse_max_bytes = 5242880

# 系统级别最大打开文件数
fs.file-max = 65535

" >> ./package/base-files/files/etc/sysctl.d/10-default.conf
p "NETKIT"
echo '
CONFIG_NETKIT=y
' >> ./target/linux/generic/config-${current_version}


p "node"
rm -rf ./feeds/packages/lang/node
clone packages-24.10 ${node_repo} ./feeds/packages/lang/node
p "golang"
rm -rf ./feeds/packages/lang/golang
clone 26.x ${golang_repo} ./feeds/packages/lang/golang
p "rust"
rm -rf ./feeds/packages/lang/rust
clone main ${rust_repo} ./feeds/packages/lang/rust

p "mount cgroupv2"
mkdir -p ./feeds/packages/utils/cgroupfs-mount/patches
cp -f ${otherdir}/yaof/PATCH/pkgs/cgroupfs-mount/90* ./feeds/packages/utils/cgroupfs-mount/patches/

p "IP/MAC 绑定"
cp -rf ${otherdir}/imm_luci_ma/applications/luci-app-arpbind ./package/add/luci-app-arpbind
sed -i 's|\.\./\.\.|$(TOPDIR)/feeds/luci|g' ./package/add/luci-app-arpbind/Makefile
p "Autocore"
cp -rf ${otherdir}/openwrt-add/autocore-arm ./package/add/autocore

p "替换 sing-box"
rm -rf ./feeds/packages/net/sing-box
cp -rf ${otherdir}/imm_pkg_ma/net/sing-box ./feeds/packages/net/sing-box
p "v2rayA"
rm -rf ./feeds/luci/applications/luci-app-v2raya ./feeds/packages/net/v2raya
cp -rf ${otherdir}/imm_luci_ma/applications/luci-app-v2raya ./feeds/luci/applications/luci-app-v2raya
cp -rf ${otherdir}/imm_pkg_ma/net/v2raya ./feeds/packages/net/v2raya
p "Passwall & OpenWrt-momo"
rm -rf ./feeds/packages/net/{xray-core,microsocks}
cp -rf ${otherdir}/openwrt-add/openwrt_helloworld ./package/add/
rm -rf ./package/add/openwrt_helloworld/{v2ray-geodata,luci-app-ssr-plus}
sed -i '/select PACKAGE_geoview/{n;s/default n/default y/;}' ./package/add/openwrt_helloworld/luci-app-passwall/Makefile
sed -i '/#dde2ff/d;/#2c323c/d' ./package/add/openwrt_helloworld/luci-app-passwall/luasrc/view/passwall/global/status.htm
p "OpenWrt-nikki"
rm -rf ./package/add/openwrt_helloworld/{mihomo-alpha,mihomo-meta}
cp -rf ${otherdir}/openwrt-add/OpenWrt-mihomo ./package/add/luci-app-nikki
rm -rf ./package/add/luci-app-nikki/mihomo-alpha
sed -i '/mihomo-alpha/d' ./package/add/luci-app-nikki/mihomo-meta/Makefile
p "HomeProxy"
cp -rf ${otherdir}/openwrt-add/homeproxy ./package/add/luci-app-homeproxy

p "MosDNS"
rm -rf ./feeds/packages/net/{v2ray-geodata,mosdns}
cp -rf ${otherdir}/openwrt-add/luci-app-mosdns ./package/add/luci-app-mosdns
cp -rf ${otherdir}/v2ray_geodata ./package/add/v2ray-geodata

p "Podman"
cp -rf ${otherdir}/podman ./package/luci-app-podman
sed -i 's#admin/#&services/#g' ./package/luci-app-podman/htdocs/luci-static/resources/podman/model/{Pod.js,Image.js,Model.js,Container.js}
sed -i 's#admin/#&services/#g' ./package/luci-app-podman/htdocs/luci-static/resources/view/podman/{overview.js,container.js,pod.js,pod-tab/info.js}
sed -i 's#admin/#&services/#g' ./package/luci-app-podman/root/usr/share/luci/menu.d/luci-app-podman.json
rm -rf ./feeds/packages/utils/podman
cp -rf ${otherdir}/imm_pkg_ma/utils/podman ./feeds/packages/utils/podman
p "Diskman 磁盘管理"
cp -rf ${otherdir}/imm_luci_ma/applications/luci-app-diskman ./package/add/luci-app-diskman
sed -i 's|\.\./\.\.|$(TOPDIR)/feeds/luci|g' ./package/add/luci-app-diskman/Makefile

p "Zerotier"
rm -rf ./feeds/luci/applications/luci-app-zerotier ./feeds/packages/net/zerotier
cp -rf ${otherdir}/imm_luci_ma/applications/luci-app-zerotier ./feeds/luci/applications/luci-app-zerotier
cp -rf ${otherdir}/imm_pkg_ma/net/zerotier ./feeds/packages/net/zerotier
p "Filebrowser 文件管理器"
cp -rf ${otherdir}/openwrt-add/openwrt_pkgs/{filebrowser,luci-app-filebrowser-go} ./package/add/
p "KMS 服务器"
cp -rf ${otherdir}/imm_luci_ma/applications/luci-app-vlmcsd ./package/add/
sed -i 's|\.\./\.\.|$(TOPDIR)/feeds/luci|g' ./package/add/luci-app-vlmcsd/Makefile
cp -rf ${otherdir}/imm_pkg_ma/net/vlmcsd ./package/add/

p "Nlbw 带宽监控"
sed -i 's/services/network/g' ./package/feeds/luci/luci-app-nlbwmon/root/usr/share/luci/menu.d/luci-app-nlbwmon.json
sed -i 's/services/network/g' ./package/feeds/luci/luci-app-nlbwmon/htdocs/luci-static/resources/view/nlbw/config.js
p "Bandix 流量监控"
cp -rf ${otherdir}/openwrt-add/{openwrt-bandix,luci-app-bandix} ./package/add/
p "终端 TTYD"
sed -i 's,services,system,g' ./package/feeds/luci/luci-app-ttyd/root/usr/share/luci/menu.d/luci-app-ttyd.json

p "晶晨宝盒"
cp -rf ${otherdir}/amlogic/luci-app-amlogic ./package/add/


p "Vermagic 内核兼容模块"
wget https://downloads.openwrt.org/releases/${latest_release}/targets/armsr/armv8/profiles.json
jq -r '.linux_kernel.vermagic' profiles.json > .vermagic
cat .vermagic
sed -i -e 's/^\(.\).*vermagic$/\1cp $(TOPDIR)\/.vermagic $(LINUX_DIR)\/.vermagic/' ./include/kernel-defaults.mk
rm -f profiles.json


p "复制自定义文件目录"
cp -rf ${ffdir}/patch/files ./files
mkdir -p ./files/etc/uci-defaults
cp -f ${ffdir}/scripts/openwrt/zzz-default-settings ./files/etc/uci-defaults/ && \
sed -i "s/build_date/${build_date}/g" ./files/etc/uci-defaults/zzz-default-settings
p "写入 banner"
length=$((${#latest_release} + ${#build_date} + 17))
echo -n "." >> ./files/etc/banner && \
for ((i=0; i<length; i++)); do echo -n "-" >> ./files/etc/banner; done && echo "." >> ./files/etc/banner
echo "|  \"OpenWrt ${latest_release} @ ${build_date}\"  |" >> ./files/etc/banner
echo -n "'" >> ./files/etc/banner && \
for ((i=0; i<length; i++)); do echo -n "-" >> ./files/etc/banner; done && echo "'" >> ./files/etc/banner


p "清理临时文件"
rm -rf ${otherdir}
find ./ -name *.orig | xargs rm -f
find ./ -name *.rej | xargs rm -f

p "容器内脚本结束"
