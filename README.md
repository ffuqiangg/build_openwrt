## 简介

本项目用于编译打包 `斐讯N1` 使用的 `openwrt`/`immortalwrt` 固件。

## 说明

- `immortalwrt 18.06 k5.4` 固件逢 5.4 内核更新当夜更新，`immortalwrt master`, `lede` 固件不定时更新。固件更新通知可关注 Telegram 频道 [N1 Openwrt firmware](https://t.me/zhenzhushan)。
- [Releases](https://github.com/ffuqiangg/build_openwrt/releases) 中的固件根据源码及编译时间不同，其包含的插件略有差异。`lede` 固件采用 5.15 内核，`immortalwrt 18.05 k5.4` 采用 5.4 内核，`immortalwrt master` 采用 6.1 内核。
- frok 使用强烈建议认真阅读 workfows 目录下的 yaml 文件，并在理解 yaml 文件的基础上根据自己的需求修改后使用。直接使用可能无法正常编译导出固件。( ⚠️ 编译 `immortalwrt master` 固件必须包含 `luci-app-amlogic` 插件，否则无法写入 emmc )
- 固件对一些命令进行了简化，如 `ungz` = `tar -xvzf`，`777` = `chmod -R 777`，`mkdirg` = `mkdir xxx && cd xxx`, `bd` = `回到上一个目录` 等，全部修改请查看固件 /etc/profile 文件。
- 在终端里输入命令起始部分再通过键盘 `↑ ↓` 可以匹配执行过的历史命令快速输入。
- 刷机方法：将固件写入U盘，插入设备并从U盘启动。进入终端输入命令 `openwrt-install-amlogic` 然后根据屏幕提示完成刷机。
- 升级固件/内核：将固件/内核文件（内核文件须包含 `dtb-xxx.tar.gz`, `modules-xxx.tar.gz`, `boot-xxx.tar.gz` 文件）放入 `/mnt/mmcblk2p4` 目录，终端输入命令 `openwrt-update-amlogic` 升级固件，`openwrt-kernel` 升级内核。

## 感谢

- 本项目固件编译方法来自于 [P3TERX](https://p3terx.com) 的 [Actions-OpenWrt](https://github.com/P3TERX/Actions-OpenWrt) 项目。
- 固件打包解决方案以及面向路由优化的内核源码源自 [Flippy](https://github.com/unifreq) 大佬的多个开源项目。
- 打包及内核编译参考了 [Ophub](https://github.com/ophub) 的开源项目中的代码。
- 部分内核文件以及对 OpenWrt 源码进行自定义的 shell 源码参考了爆操老哥 [Breakings](https://github.com/breakings) 的代码。
- 感谢 [OpenWrt](https://github.com/openwrt/openwrt) , [Immortalwrt](https://github.com/immortalwrt/immortalwrt) , [LEDE](https://github.com/coolsnowwolf/lede) 等项目对开源路由的贡献。
