<img width="768" src="https://raw.githubusercontent.com/ffuqiangg/build_openwrt/main/img/phicomm-n1.jpg" align="center">

##

本项目用于编译 `斐讯 N1` 使用的 `OpenWrt` `ImmortalWrt` `LEDE` `iStoreOS` 固件。

### 说明

- 由于仓库的代码大部分时间都处于不可用的状态，所以并不建议 fork 使用。除非能够自行排查和修复错误。
- ImmortalWrt-18.06，ImmortalWrt-24.10，OpenWrt-24.10 固件采用 [Flippy](https://github.com/unifreq) 大佬的方案由 Armbian 内核打包制作，LEDE 及 iStoreOS 为原生编译。
- 固件不定时更新，更新通知可关注 Telegram 频道 [N1 Openwrt firmware](https://t.me/zhenzhushan)，下载前往 [Releases](https://github.com/ffuqiangg/build_openwrt/releases) 。
- 默认 IP：192.168.1.99， 默认密码：password 。
- 插件：PassWall，v2rayA，Homeproxy，OpenClash，Nikki，Momo，DAED，MosDNS，硬盘休眠，KMS，FileBrowser，Frpc，网络共享，FTP 服务器，DockerMan，Docker-Compose，UPNP 。
- 各固件包含的科学插件略有差别，具体区别见 release 说明。
- ImmortalWrt-24.10，OpenWrt-24.10 固件经过特殊优化可避免安装 kmod 内核模块时出现 pkg_hash 错误。iStoreOS，LEDE 固件可以通过命令一键部署本地 kmod 源解决 kmod 安装问题（见 release 说明）。
- 固件对一些命令进行了简化，如 `ungz = tar -xvzf`，`777 = chmod -R 777`，`mkdirg X = mkdir -p X && cd X` 等，详情可查看仓库 [shinit](files/init/etc/shinit) 文件。
- 在终端里输入命令起始部分再通过键盘 `↑ ↓` 可以匹配执行过的历史命令快速输入。
- 固件刷机：具体方法请认真阅读 ⌈ [使用说明](doc/readme.md) ⌋ 。

> [!IMPORTANT]
> iStoreOS 固件相对于其官方固件仅保留插件商店，可以看作包含 iStore 插件商店的原版 OpenWrt-22.03 固件。  
> 带 Pre-release 标签的是测试固件随时删除，且可能有各种问题请谨慎下载使用。

### 感谢

- 本项目源自于 [P3TERX](https://p3terx.com) 的 [Actions-OpenWrt](https://github.com/P3TERX/Actions-OpenWrt) 项目。
- 固件打包方案来自 [Flippy](https://github.com/unifreq) 的 [openwrt_packit](https://github.com/unifreq/openwrt_packit) 以及 [Ophub](https://github.com/ophub) 的 [amlogic-s9xxx-openwrt](https://github.com/ophub/amlogic-s9xxx-openwrt) 项目。
- 本项目使用的一部分补丁取自 [YAOF](https://github.com/QiuSimons/YAOF) 项目，仓库重构时也大量参考了该项目。
- 感谢 [OpenWrt](https://github.com/openwrt/openwrt) , [Immortalwrt](https://github.com/immortalwrt/immortalwrt) , [LEDE](https://github.com/coolsnowwolf/lede) , [IStoreOS](https://github.com/istoreos/istoreos) 等项目以及所有插件作者对开源路由所作的贡献。

##

<p align="center">
  <a href="https://t.me/ffuqiangg">
    <img src="https://img.shields.io/badge/-Telegram-413f42?style=flat&logo=telegram&logoColor=white">
  </a>
  <a href="mailto:ffuqiangg@gmail.com">
    <img src="https://img.shields.io/badge/-Gmail-red?style=flat&logo=gmail&logoColor=white">
  </a>
  <a href="https://hub.docker.com/u/ffuqiangg">
    <img src="https://img.shields.io/badge/-Docker-informational?style=flat&logo=docker&logoColor=white">
  </a>
<p>
