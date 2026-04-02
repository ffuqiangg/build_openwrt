### 📝 基础信息

- 默认 IP：192.168.1.99 ， 密码：password
- sing-box 脚本文档： ⌈ [sing-box OpenWrt 安装与配置指南](https://github.com/ffuqiangg/build_openwrt/blob/main/doc/sing-box.md) ⌋ 、mihomo 脚本文档：⌈ [Mihomo 核心轻量化启动器说明文档](https://github.com/ffuqiangg/build_openwrt/blob/main/doc/mihomo.md) ⌋
- 各个科学插件如果不知道该如何选择可参考 **Readme 文档** 的 [科学上网插件对比](https://github.com/ffuqiangg/build_openwrt/blob/main/doc/readme.md#4-%EF%B8%8F-科学上网插件对比) 部分。
- LEDE 及 iStoreOS 固件执行以下命令可快速部署本地 kmod 源。（ 占用存储空间 < 20MiB ）

```bash
sh -c "$(curl -ksS https://testingcf.jsdelivr.net/gh/ffuqiangg/build_openwrt@main/scripts/feeds.sh)"
```

##

### ✨ 更新内容

- 插件调整：新增 qBittorrent、Bandix 流量监控，取消 DDNS、daed、带宽监控。
- 新增内存压缩功能。LuCI 页面 `系统` -> `系统` -> `ZRam 设置` 可调整相关参数。
- OpenWrt 和 ImmortalWrt 固件更新到 25.12（ 6.12 内核 ）启用 apk 包管理，apk 命令使用方法阅读官方 ⌈ [opkg 到 apk 对照速查表](https://openwrt.org/zh/docs/guide-user/additional-software/opkg-to-apk-cheatsheet) ⌋
- iStoreOS 固件切换到 istoreos-24.10 分支，使用 fw4 ，插件与其它固件保持一致。（ OpenClash 没有了 ）
- iStoreOS 和 LEDE 固件升级到 6.6 内核，使用 hy2 节点如果出现断流问题可尝试在 Nikki / Momo 插件中开启 `禁用 quic-go 的通用分段卸载`，sing-box / mihomo 脚本和 Homeproxy 插件会自动处理。
