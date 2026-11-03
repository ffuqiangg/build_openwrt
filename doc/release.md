### 📝 基础信息

- 默认IP: 192.168.1.99 ，密码: password
- sing-box 脚本文档 : ⌈ [sing-box OpenWrt 安装与配置指南](https://github.com/ffuqiangg/build_openwrt/blob/main/doc/sing-box.md) ⌋ 、mihomo 脚本文档 : ⌈ [Mihomo 核心轻量化启动器说明文档](https://github.com/ffuqiangg/build_openwrt/blob/main/doc/mihomo.md) ⌋
- 各个科学插件如果不知道该如何选择可参考 **Readme 文档** 的 [科学上网插件对比](https://github.com/ffuqiangg/build_openwrt/blob/main/doc/readme.md#4-%EF%B8%8F-科学上网插件对比) 部分。
- LEDE 及 iStoreOS 固件执行以下命令可快速部署本地 kmod 源。(占用存储空间 < 20MiB)

```bash
sh -c "$(curl -ksS https://testingcf.jsdelivr.net/gh/ffuqiangg/build_openwrt@main/scripts/feeds.sh)"
```

##

### ✨ 更新内容

- 插件调整 : 取消编译 homeproxy 。