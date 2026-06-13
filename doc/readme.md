## Phicomm N1 固件安装与使用指南

欢迎使用本仓库编译的 N1 固件。本指南旨在帮助你快速完成系统部署。

### 🚀 快速上手

本仓库固件主要分为两类，其安装逻辑略有不同
- 直编版 : LEDE, iStoreOS (采用 Squashfs 格式)
- 打包版 : ImmortalWrt, OpenWrt (基于 Armbian 内核打包)

> [!TIP]
> **默认服务说明：** 为了节省资源，固件默认禁用了 **podman** 和 **ttyd** 。
> - 启用方法 : 在 `系统 -> 启动项` 页面 `启用` + `启动` 对应服务。
> - 首次启动 podman 务必在 `luci-app-podman -> 网络` 页检查初始化状态，出现 ❌ 则点击该符号完成初始化配置。

##

### 1. 🛠️ 安装前准备：调整分区空间

在写入 EMMC 前，你可以根据需求调整系统分区大小 (默认 1G) 。  
注意 : 增大系统分区会相应压缩 podman 的可用空间。如无需调整，请跳过此步。

1. **ImmortalWrt / OpenWrt** ：将 `NUM` 修改为所需大小 (单位 MiB)
```bash
sed -i "/^ROOT/s/1024/NUM/g" /usr/sbin/openwrt-install-amlogic
```

2. **LEDE / iStoreOS** ：将 `NUM` 修改为所需大小 (单位 MiB)
```bash
sed -i "s/1824/$((800 + NUM))/g" /usr/sbin/install-to-emmc.sh
```

### 2. 💿 ImmortalWrt / OpenWrt 安装与更新

此类固件已完成大量优化，直接写入 EMMC 即可直接开始使用。

1. 安装系统 (二选一)
- **LuCI** 页面 : `系统 -> 晶晨宝盒 -> 安装 OpenWrt`，选择型号点击 `安装`
- **SSH** 终端 : 连接 SSH 后输入
```bash
echo -e "101\n2\n" | openwrt-install-amlogic
```

2. 更新系统 (二选一)
- **LuCI** 页面 : 在 `晶晨宝盒 -> 手动上传更新` 页面上传 `.img.gz` 固件，点击 `升级`
- **SSH** 终端 : 将固件上传至 `/mnt/mmcblk2p4` ，执行
```bash
openwrt-update-amlogic
```

> [!IMPORTANT]
> - **严禁改动系统挂载点！** 否则可能导致无法开机。
> - 更新前务必将固件解压为 `.img.gz` 格式，否则系统无法识别。
> - Docker 容器如需映射 EMMC 路径，请务必指向 `/mnt/mmcblk2p4` 。

### 3. 💾 LEDE / iStoreOS 安装与配置

这类固件安装后，需额外手动挂载分区以发挥最佳性能。

1. 安装系统 : 连接 ssh，执行以下命令
```bash
echo -e "y\n" | install-to-emmc.sh
```

2. 挂载 overlay 分区 (iStoreOS 系统可跳过这一步)
   1. 进入 `系统 -> 挂载点` 页面点击 `生成配置`，`修改` 设备 `/dev/mmcblk1p3` 。
   2. 在弹出页面中确认已 `启用`，挂载点选择 `作为外部 overlay 使用 (/overlay)` ，保存。
   3. 回到 `挂载点` ，取消启用原本 overlay 分区 (通常在第一行)，点击 `保存并应用`。
   4. 重启系统生效。

3. 挂载 docker 分区
   1. 进入 `系统 -> 挂载点` 页面点击 `生成配置`，`修改` 设备 `/dev/mmcblk1p4` 。
   2. 在弹出窗口中确认已 `启用`，挂载点选择 `作为 Docker 数据分区 (/opt)` (没有选项就手动输入 `/opt`)，保存。
   3. 回到 `挂载点` ，点击 `保存并应用` 按钮。
   4. 重启系统生效。

4. 更新系统 : 前往 `系统 -> 备份与升级 -> 刷写新的固件`，同样需使用 `.img.gz` 格式

> [!IMPORTANT]
> Docker 容器如需映射 EMMC 路径，请务必指向 `/opt` 。

### 4. 🛡️ 科学上网插件对比

| 插件名称 | ipv6 | 内核 | 特点与评价 | 文档 |
| :--- | :---: | :---: | :--- | :--- |
| passwall | ✅ | 可选 | 老牌科学插件，功能完善。使用 xray / sing-box 核心可一定程度配置分流。 | [Github](https://github.com/Openwrt-Passwall/openwrt-passwall) |
| nikki | ✅ | mihomo | 通过 LuCI 可进行极细致的调整，但分流规则的调整不够灵活。 | [Wiki](https://github.com/nikkinikki-org/OpenWrt-nikki/wiki) |
| momo | ✅ | sing-box | 插件着力于配置防火墙，配置文件须用户自行调整，适合搭配订阅转换服务使用。 | [Wiki](https://github.com/nikkinikki-org/OpenWrt-momo/wiki) |
| homeproxy | ✅ | sing-box | 无 Web 面板，优点是无需 sing-box 订阅。适合使用大陆白名单模式的用户。 | [Github](https://github.com/immortalwrt/homeproxy) |
| V2rayA | ✅ | xray | 通过专用的 RoutingA 语言可自由配置 DNS 和路由规则。 | [Docs](https://v2raya.org/docs/prologue/introduction/) |
| sing-box 脚本 | ❌ | sing-box | 用于裸核 sing-box 的脚本。在原版基础上增加了多订阅合并功能。 | [Docs](sing-box.md) [Wiki](https://sing-box.sagernet.org/zh/) |
| mihomo 脚本 | ✅ | mihomo | 裸核 mihomo 启动器，原汁原味的 mihomo 体验。 | [Docs](mihomo.md) [Wiki](https://wiki.metacubex.one) |
