<p align="center">
  <img src="https://github.com/user-attachments/assets/6efc6401-c9f7-46e5-91a7-2c956fe3261c" alt="logo" width="768" />
</p>

<p align="center">本项目用于编译斐讯 N1 使用的 OpenWrt , ImmortalWrt , LEDE , iStoreOS 固件</p>
    
<p align="center">
  <a href="https://github.com/ffuqiangg/build_openwrt/stargazers"><img src="https://img.shields.io/github/stars/ffuqiangg/build_openwrt?color=ffcb47&labelColor=black&logo=github&label=Stars" /></a>
  <a href="https://github.com/ffuqiangg/build_openwrt/releases"><img src="https://img.shields.io/github/downloads/ffuqiangg/build_openwrt/total?color=2c9678&labelColor=black&logo=github&label=Downloads" /></a>
  <a href="https://github.com/ffuqiangg/build_openwrt/releases/latest"><img src="https://img.shields.io/github/v/release/ffuqiangg/build_openwrt?color=2775b6&labelColor=black&logo=github&label=Latest%20Release" /></a>
  <a href="https://t.me/zhenzhushan"><img src="https://img.shields.io/badge/Follow-blue?color=813c85&logo=telegram&logoColor=white&labelColor=black" /></a>
</p>

##

### 📝 说明

- 由于仓库的代码大部分时间都处于不可用的状态，所以并不建议 fork 使用。除非能够自行排查和修复错误。
- ImmortalWrt，OpenWrt 固件由 Armbian 内核打包制作，LEDE 及 iStoreOS 为原生编译。
- 固件不定时更新，更新通知可关注 Telegram 频道 [N1 Openwrt firmware](https://t.me/zhenzhushan)，下载前往 [Releases](https://github.com/ffuqiangg/build_openwrt/releases) 。
- 默认 IP：192.168.1.99， 默认密码：password 。
- 插件：PassWall，v2rayA，Homeproxy，Nikki，Momo，MosDNS，硬盘休眠，KMS，FileBrowser，Frpc，网络共享，FTP 服务器，DockerMan，Docker-Compose，UPNP，Bandix 流量监控。
- ImmortalWrt，OpenWrt 固件经过特殊优化可避免安装 kmod 内核模块时出现 pkg_hash 错误。iStoreOS，LEDE 固件可以通过命令一键部署本地 kmod 源解决 kmod 安装问题（见 release 说明）。
- 固件对一些命令进行了简化，如解压 .gz 文件 `ungz`，设置可执行权限 `mx`，创建并进入目录 `mkdirg` 等，详情可查看仓库 [shinit](patch/files/etc/shinit) 文件。
- 在终端里输入命令起始部分再通过键盘 <kbd>▲</kbd> <kbd>▼</kbd> 可以匹配执行过的历史命令快速输入。
- 固件刷机：具体方法请认真阅读 ⌈ [使用说明](doc/readme.md) ⌋ 。

> [!NOTE]
> iStoreOS 固件相对于其官方固件仅保留插件商店，可以看作包含 iStore 插件商店的原版 OpenWrt-24.10 固件。

### 🙏 致谢

- 本项目源自于 [P3TERX](https://p3terx.com) 的 [Actions-OpenWrt](https://github.com/P3TERX/Actions-OpenWrt) 项目。
- 固件打包方案来自 [Ophub](https://github.com/ophub) 的 [amlogic-s9xxx-openwrt](https://github.com/ophub/amlogic-s9xxx-openwrt) 项目。
- 本项目使用的一部分补丁取自 [YAOF](https://github.com/QiuSimons/YAOF) 项目，使用 docker 编译的代码来自 [LynnOS](https://github.com/NuoFang6/LynnOS) 项目。
- 感谢 [OpenWrt](https://github.com/openwrt/openwrt) , [Immortalwrt](https://github.com/immortalwrt/immortalwrt) , [LEDE](https://github.com/coolsnowwolf/lede) , [IStoreOS](https://github.com/istoreos/istoreos) 等项目以及所有插件作者对开源路由所作的贡献。
