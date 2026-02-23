### 基础信息

- 默认 IP：192.168.1.99 | 默认密码：password
- sing-box 裸核运行安装使用方法见 ⌈ [sing-box 安装使用文档](https://github.com/ffuqiangg/build_openwrt/blob/main/doc/sing-box.md) ⌋
- packages.zip 无须下载，LEDE 及 iStoreOS 固件可通过下面的命令将其部署为本地源（ 占用存储空间 < 20MiB ）
```bash
sh -c "$(curl -ksS https://testingcf.jsdelivr.net/gh/ffuqiangg/build_openwrt@main/scripts/feeds.sh)"
```

##

### 更新内容

- OpenWrt 和 ImmortalWrt 固件更新到 25.12（ 6.12 内核 ) 启用 apk 包管理，apk 命令使用方法阅读官方 ⌈ [opkg 到 apk 对照速查表](https://openwrt.org/zh/docs/guide-user/additional-software/opkg-to-apk-cheatsheet) ⌋
- iStoreOS 固件切换到 istoreos-24.10 分支，使用 fw4 ，插件调整与其它固件保持一致。（ OpenClash 没有了 ）
- iStoreOS 和 LEDE 固件升级到 6.6 内核，如果使用 hy2 节点可在 Nikki/Momo 插件中开启 `禁用 quic-go 的通用分段卸载` 开关解决断流问题，sing-box 裸核脚本和 Homeproxy 插件会自动处理无须理会。
