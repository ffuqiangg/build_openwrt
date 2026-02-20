<img src="https://img.shields.io/github/downloads/ffuqiangg/build_openwrt/BUILD_DATE/total?logo=github&color=orange" alt="downloads" align="right">

### 基础信息

- 默认 IP：192.168.1.99 | 默认密码：password
- sing-box 裸核运行安装使用方法见 ⌈ [sing-box 安装使用文档](https://github.com/ffuqiangg/build_openwrt/blob/main/doc/sing-box.md) ⌋
- packages.zip 无须下载，LEDE 及 iStoreOS 固件可通过下面的命令将其部署为本地源（ 占用存储空间 < 20MiB ）
```bash
sh -c "$(curl -ksS https://testingcf.jsdelivr.net/gh/ffuqiangg/build_openwrt@main/scripts/feeds.sh)"
```

##

### 更新内容

- 增加 docker 启动限制，只有在 dockerman 配置页面开启 `自动启动` 时才能启动。
- iStoreOS 固件中的 iStore 插件 LuCI 菜单移动至 `服务` 下。
- 所有固件全部使用 nginx 替换 uhttpd ，以及其它一些优化。
- 由于每次发的新版其实没啥变化，所以不再编译 ImmortalWrt-18.06 。（需要的话直接下载旧版）
