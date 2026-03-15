### 基础信息

- 默认 IP：192.168.1.99 | 默认密码：password
- sing-box 裸核脚本使用方法见 ⌈ [sing-box 安装使用文档](https://github.com/ffuqiangg/build_openwrt/blob/main/doc/sing-box.md) ⌋
- packages.zip 无须下载，LEDE 及 iStoreOS 固件可通过下面的命令将其部署为本地源（ 占用存储空间 < 20MiB ）
```bash
sh -c "$(curl -ksS https://testingcf.jsdelivr.net/gh/ffuqiangg/build_openwrt@main/scripts/feeds.sh)"
```

### 科学插件如何取舍

| 插件名称 | ipv6 | 内核 | 特点与评价 | 文档 |
| :--- | :---: | :---: | :--- | :--- |
| passwall | ✅ | 可选 | 老牌科学插件，功能完善。无 Web 面板但通过 LuCI 可设置分流规则。 | [Github](https://github.com/Openwrt-Passwall/openwrt-passwall) |
| nikki | ✅ | mihomo | 通过 LuCI 可进行极细致的调整，但分流规则的调整不够灵活。 | [Wiki](https://github.com/nikkinikki-org/OpenWrt-nikki/wiki) |
| momo | ✅ | singbox | 须手动修改入站。推荐自己写一个满足要求的转换模板，配合订阅转换服务使用。 | [Wiki](https://github.com/nikkinikki-org/OpenWrt-momo/wiki) |
| homeproxy | ✅ | singbox | 缺失一些基础功能且无 Web 面板，设置分流较为复杂。优点是无需 sing-box 订阅即可使用。 | [Github](https://github.com/immortalwrt/homeproxy) |
| V2rayA | ✅ | xray | 支持的科学协议有限。分流和 DNS 均需手写配置。 | [intro](https://v2raya.org/docs/prologue/introduction/) |
| sing-box 脚本 | ❌ | singbox | 需要 sing-box 订阅，可以方便的设置分流。没有 LuCI 但支持 Web 面板。 | [Docs](https://github.com/ffuqiangg/build_openwrt/blob/main/doc/sing-box.md) |
| mihomo 脚本 | ✅ | mihomo | mihomo 启动器。最大的特点是多个订阅会自动合并。没有 LuCI 但支持 Web 面板。 | [Conf](https://wiki.metacubex.one/example/conf/#__tabbed_1_2) |

##

### 更新内容

- 所有固件不再编译 daed 和 ddns ，如需要 ddns 可通过 LuCI `软件包` 或 apk / opkg 命令安装。
- OpenWrt 和 ImmortalWrt 固件更新到 25.12（ 6.12 内核 ）启用 apk 包管理器，apk 命令使用方法阅读官方 ⌈ [opkg 到 apk 对照速查表](https://openwrt.org/zh/docs/guide-user/additional-software/opkg-to-apk-cheatsheet) ⌋
- iStoreOS 固件切换到 istoreos-24.10 分支，使用 fw4 ，插件与其它固件保持一致。（ OpenClash 没有了 ）
- iStoreOS 和 LEDE 固件升级到 6.6 内核，如果使用 hy2 节点可在 Nikki / Momo 插件中开启 `禁用 quic-go 的通用分段卸载` 开关解决断流问题，sing-box / mihomo 脚本和 Homeproxy 插件会自动处理无须理会。
