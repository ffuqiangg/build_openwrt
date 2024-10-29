<img width="768" src="https://raw.githubusercontent.com/ffuqiangg/build_openwrt/main/img/phicomm-n1.jpg" align="center">

##

本项目用于编译 `斐讯N1` 使用的 `OpenWrt` `ImmortalWrt` `LEDE` `IStoreOS` 固件。

### 说明

- 由于仓库的代码大部分时间都处于不可用的状态，所以并不建议 fork 使用。除非能够自行排查和修复错误。
- ImmortalWrt-18.06 ImmortalWrt-23.05 OpenWrt-23.05 固件均采用 [Flippy](https://github.com/unifreq) 大佬的方案由 Armbian 内核打包制作，LEDE IStoreOS 由于硬件原生支持，为直接编译。
- 固件不定时更新，更新通知可关注 Telegram 频道 [N1 Openwrt firmware](https://t.me/zhenzhushan)，下载前往 [Releases](https://github.com/ffuqiangg/build_openwrt/releases)
- 默认 IP：192.168.1.99，  默认密码：password
- 插件：PassWall，v2rayA，Homeproxy，OpenClash，mihomo，DAED，MosDNS，硬盘休眠，KMS，FileBrowser，Frpc，网络共享，FTP服务器，DockerMan，DocKer-Compose，UPNP，VerySync  
- 固件对一些命令进行了简化，如 `ungz = tar -xvzf`，`777 = chmod -R 777`，`mkdirg = 创建并进入目录`，`bd = 回到之前目录` 等，详情可查看仓库 patch/files/etc/shinit 文件。
- 在终端里输入命令起始部分再通过键盘 `↑ ↓` 可以匹配执行过的历史命令快速输入。
- 刷机方法：将固件写入U盘，插入设备并从U盘启动。进入终端输入命令 `openwrt-install-amlogic` 然后根据屏幕提示完成刷机。
- 升级固件/内核：将固件/内核文件（内核文件须包含 `dtb-xxx.tar.gz`, `modules-xxx.tar.gz`, `boot-xxx.tar.gz` 文件）放入 `/mnt/mmcblk2p4` 目录，终端输入命令 `openwrt-update-amlogic` 升级固件，`openwrt-kernel` 升级内核。

> [!IMPORTANT]
> **ImmortalWrt-18.06** 不含 mihomo、Homeproxy、DAED，**ImmortalWrt-23.05** 不含 OpenClash，**LEDE** 不含 mihomo、Homeproxy、DAED，**OpenWrt-23.05** 不含 Openclash、Homeproxy，**IStoreOS** 不含 Homeproxy、OpenClash、DAED。

> [!TIP]
> OpenWrt-23.05、IStoreOS 纯 Sing-Box 核心使用方法阅读 [sing-Box 使用文档](docs/sing-box.md)，LEDE 固件使用 Sing-Box 裸跑可到 Telegram 频道下载替换文件。

### 感谢

- 本项目固件编译方法来自于 [P3TERX](https://p3terx.com) 的 [Actions-OpenWrt](https://github.com/P3TERX/Actions-OpenWrt) 项目。
- 固件打包解决方案以及面向路由优化的内核源码源自 [Flippy](https://github.com/unifreq) 大佬的多个开源项目。
- 打包及内核编译参考了 [Ophub](https://github.com/ophub) 的开源项目中的代码。
- shell 脚本参考了爆操老哥 [Breakings](https://github.com/breakings) 及 [YAOF](https://github.com/QiuSimons/YAOF) 项目的代码。
- 感谢 [OpenWrt](https://github.com/openwrt/openwrt) , [Immortalwrt](https://github.com/immortalwrt/immortalwrt) , [LEDE](https://github.com/coolsnowwolf/lede) , [IStoreOS](https://github.com/istoreos/istoreos) 等项目对开源路由的贡献。

##

<p align="center">
<a href="https://t.me/ffuqiangg"><img src="https://img.shields.io/badge/-Telegram-413f42?style=flat&logo=telegram&logoColor=white"></a>
<a href="mailto:ffuqiangg@gmail.com"><img src="https://img.shields.io/badge/-Gmail-red?style=flat&logo=gmail&logoColor=white"></a>
<a href="https://hub.docker.com/u/ffuqiangg"><img src="https://img.shields.io/badge/-Docker-informational?style=flat&logo=docker&logoColor=white"></a>
<p>
