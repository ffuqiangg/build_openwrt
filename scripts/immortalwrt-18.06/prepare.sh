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


p "克隆 immortalwrt 到 ${workdir}/openwrt"
. set_env "wrtdir" "${workdir}/openwrt"
umask 0022
clone openwrt-18.06-k5.4 ${immortalwrt_repo} ${wrtdir}
pushd ${wrtdir}
git config core.filemode false # 忽略权限变更
popd


p "下载其它仓库"
. set_env "otherdir" "${workdir}/other"
clone master ${openclash_repo} ${otherdir}/openclash &
clone main ${amlogic_repo} ${otherdir}/amlogic &
clone v4 ${sbwml_mosdns_repo} ${otherdir}/mosdns &
clone master ${v2ray_geodata_repo} ${otherdir}/v2ray_geodata &
clone 18.06 ${v2raya_repo} ${otherdir}/v2raya &
wait && sync


p ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"


p "进入编译目录 ${wrtdir}"
cd ${wrtdir}
    

p "更新 Feeds"
./scripts/feeds update -a
./scripts/feeds install -a


p "卸载无法编译的包"
./scripts/feeds uninstall prometheus-node-exporter-lua

p "应用自定义修改"
mkdir -p ./package/add
p "使用 O2 级别的优化"
sed -i 's/Os/O2/g' ./include/target.mk
p "确保加载 /etc/shinit"
echo -e "\n[ -f /etc/shinit ] && . /etc/shinit" >> ./package/base-files/files/etc/profile


p "调整 default-settings"
rm -f ./package/emortal/default-settings/files/openwrt_banner
sed -i '/etc$/{N;N;d}' ./package/emortal/default-settings/Makefile


p "MosDNS"
rm -rf ./feeds/packages/net/v2ray-geodata
cp -rf ${otherdir}/mosdns/luci-app-mosdns ./package/add/luci-app-mosdns
cp -rf ${otherdir}/v2ray_geodata ./package/add/v2ray-geodata
echo 'account.synology.com
ddns.synology.com
checkip.synology.com
checkip.dyndns.org
checkipv6.synology.com
ntp.aliyun.com
cn.ntp.org.cn
ntp.ntsc.ac.cn' >> package/add/luci-app-mosdns/root/etc/mosdns/rule/whitelist.txt
p "OpenClash"
rm -rf ./feeds/luci/applications/luci-app-openclash
cp -rf ${otherdir}/openclash/luci-app-openclash ./feeds/luci/applications/luci-app-openclash
p "V2raya"
cp -rf ${otherdir}/v2raya ./package/add/luci-app-v2raya

p "Docker 容器"
sed -i '/auto_start/d' ./feeds/luci/applications/luci-app-dockerman/root/etc/uci-defaults/luci-app-dockerman
sed -i '/^start_service/a\\t[ "$(uci -q get dockerd.globals.auto_start)" -eq "0" ] && return 1\n' ./feeds/packages/utils/dockerd/files/dockerd.init
pushd package/feeds/luci/luci-app-dockerman
bash ${ffdir}/scripts/docker.sh
popd
p "Filebrowser 文件浏览器"
sed -i "s,PKG_VERSION:=.*,PKG_VERSION:=2\.32\.0," ./feeds/packages/utils/filebrowser/Makefile
sed -i "s,PKG_MIRROR_HASH:=.*,PKG_MIRROR_HASH:=61e9de6b2d396614f45be477e5bb5aad189e7bb1155a3f88800e02421bd6cc2b," ./feeds/packages/utils/filebrowser/Makefile
sed -i 's,nas,services,g;s,NAS,Services,g' ./feeds/luci/applications/luci-app-filebrowser/luasrc/controller/filebrowser.lua
sed -i 's,nas,services,g' ./feeds/luci/applications/luci-app-filebrowser/luasrc/view/filebrowser/filebrowser_status.htm


p "Samba4"
sed -i 's,nas,services,g' ./feeds/luci/applications/luci-app-samba4/luasrc/controller/samba4.lua
p "Cpufreq"
sed -i 's,system,services,g' ./feeds/luci/applications/luci-app-cpufreq/luasrc/controller/cpufreq.lua
p "硬盘休眠"
sed -i 's,nas,services,g' ./feeds/luci/applications/luci-app-hd-idle/luasrc/controller/hd_idle.lua
p "FTP 服务器"
sed -i 's,nas,services,g;s,NAS,Services,g' ./feeds/luci/applications/luci-app-vsftpd/luasrc/controller/vsftpd.lua
p "Rclone"
sed -i 's,nas,services,g;s,NAS,Services,g' ./feeds/luci/applications/luci-app-rclone/luasrc/controller/rclone.lua
p "Nlbw 带宽监控"
sed -i 's|admin\",|& \"network\",|g;s,admin/,&network/,g' ./feeds/luci/applications/luci-app-nlbwmon/luasrc/controller/nlbw.lua
sed -i 's,admin/,&network/,g' ./feeds/luci/applications/luci-app-nlbwmon/luasrc/model/cbi/nlbw/config.lua
sed -i 's,admin/,&network/,g' ./feeds/luci/applications/luci-app-nlbwmon/luasrc/view/nlbw/{backup.htm,display.htm}

p "晶晨宝盒"
cp -rf ${otherdir}/amlogic/luci-app-amlogic ./package/add/luci-app-amlogic


p "复制自定义文件目录"
cp -rf ${ffdir}/patch/files ./files
mkdir -p ./files/etc/{uci-defaults,openclash/core}
cp -f ${ffdir}/scripts/immortalwrt-18.06/zzz-default-settings ./files/etc/uci-defaults/
wget -qO- https://github.com/vernesong/OpenClash/raw/core/master/meta/clash-linux-arm64.tar.gz | tar xOvz > ./files/etc/openclash/core/clash_meta
chmod +x ./files/etc/openclash/core/clash*
echo -e "\n\033[34mImmortalWrt\033[0m 18.06 | ${build_date//./-}\n" > ./files/etc/banner


p "清理临时文件"
rm -rf ${otherdir}
find ./ -name *.orig | xargs rm -f
find ./ -name *.rej | xargs rm -f

p "容器内脚本结束"
