## 简介

本项目用于编译打包 `斐讯N1` 使用的 `openwrt`/`immortalwrt` 固件。

## 说明

- Releases 中固件根据源码及编译时间不同，其包含的插件也略有差异。
- 如要 frok 使用务必添加 `GH_TOKEN` 至 secret，想要编译完成后收到 Telegram 通知，需要在 secret 中添加 `TELEGRAM_TO` (用户id)，`TELEGRAM_TOKEN` (tg token)。
- 固件对一些命令进行了简化，如 `ungz` = `tar -xvzf`，`777` = `chmod -R 777`，`mkdirg` = 创建并进入目录等，全部修改请查看固件 /etc/profile 文件。
- 在终端里输入命令起始部分再通过键盘 `↑ ↓` 可以匹配搜索曾经执行过的命令快速输入。

## 感谢

- [P3TERX](https://p3terx.com)
- [Microsoft Azure](https://azure.microsoft.com)
- [GitHub Actions](https://github.com/features/actions)
- [OpenWrt](https://github.com/openwrt/openwrt)
- [Lean's OpenWrt](https://github.com/coolsnowwolf/lede)
- [Immortalwrt](https://github.com/immortalwrt/immortalwrt)
- [Ophub](https://github.com/ophub)
- [Flippy](https://github.com/unifreq)
- [Breakings](https://github.com/breakings)
