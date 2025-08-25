# Phicomm N1

本仓库编译的 N1 固件大致上分为 LEDE，iStoreOS 的直接编译和 ImmortalWrt，OpenWrt 的 Armbian 内核打包两种类型，在刷机和初始化配置上会有些不同。每个固件由于代码差异所以包含的插件也会有一定的区别，详细情况见 Releases 备注。

## 使用说明

本仓库的固件默认禁用了 docker 和 ttyd 服务，ttyd 服务可前往 `系统` - `启动项` 页面找到对应条目点击其右侧的 `停用` / `已禁用` 和 `启动` 按钮启用对应服务。docker 的启用可以到 DockerMan 概览页面点击启动，并在其配置页面勾选自动启动项。  
`禁用 ttyd 只影响终端网页的使用，对依赖 ttyd 的插件和 ssh 连接设备操作无任何影响。`

### 1. 安装前准备

EMMC 中，ImmortalWrt 和 OpenWrt 系统默认的系统分区为 820M，LEDE 和 iStoreOS 系统默认的 overlay 分区大小为 1G。在将系统写入 EMMC 前可以通过下面的命令调整大小，但修改后预留给 docker 的运行空间也会相应的变化 ( 系统/overlay 增大 > docker 空间缩小 )。如果不修改请忽略这部分内容。

1. ImmortalWrt 和 OpenWrt 系统，将命令中的 `NUM` 修改为你想要的大小，单位 MiB。
```bash
sed -i '/^ROOT/s/820/NUM/g' /usr/sbin/openwrt-install-amlogic
```

2. LEDE 和 iStoreOS 系统，将命令中的 `NUM` 修改为你想要的大小，单位 MiB。
```bash
sed -i "s/1788/$((764 + NUM))/g" /usr/sbin/install-to-emmc.sh
```

### 2. ImmortalWrt、OpenWrt 固件的安装使用

这类固件由于打包的过程中已经完成了大量的前期配置和优化工作，基本上刷入 EMMC 就可以直接使用了。

1. 安装系统：  
第一种方法登录 LuCI 页面，在 `系统` - `晶晨宝盒` - `安装 OpenWrt` 页面选择好设备型号，点击 `安装` 按钮，等到页面提示安装完成。  
第二种方法连接 ssh，输入命令
```bash
echo -e "101\n1\n" | openwrt-install-amlogic
```
`如果使用的 ImmortalWrt-18.06 系统需要将命令中的 101 替换为 11`

2. 更新系统：  
第一种方法登录 LuCI 页面，在 `系统` - `晶晨宝盒` - `手动上传更新` 页面，点击 `选择文件` - `上传` 按钮将固件上传到设备，上传成功后页面下方会出现 `升级 OpenWrt 固件` 按钮，点击即可。  
第二种方法将升级用的固件文件传输到 N1 的 `/mnt/mmcblk2p4` 目录，接着输入命令
```bash
openwrt-update-amlogic
```

> [!IMPORTANT]
> - **一定不要改动系统挂载点，一定不要改动系统挂载点，一定不要改动系统挂载点。**
> - 更新系统两种方法都须先将固件文件解压为 `.img.gz` 格式再上传，否则系统无法识别。
> - 如果使用 `晶晨宝盒` - `在线下载更新` 功能更新固件会变为 [breakings](https://github.com/breakings/OpenWrt) 或 [ophub](https://github.com/ophub/amlogic-s9xxx-openwrt) 仓库的固件。
> - 系统可单独升级内核但不建议。尤其是 ImmortalWrt-23.05 和 OpenWrt-23.05 固件，其经过特殊优化解决了安装内核模块报错的问题，单独升级内核可能使其失效。
> - 使用过程中 docker 容器中的目录如需映射到 EMMC 务必映射到 `/mnt/mmcblk2p4` 目录。

### 3. LEDE、iStoreOS 固件的安装使用

这类原生固件在安装好之后还需要挂载 overlay 和 docker 分区。iStoreOS 固件默认已挂载好 overlay 分区，可跳过该步骤。

1. 安装系统：连接 ssh，输入命令 
```bash
echo -e "y\n" | install-to-emmc.sh
```

2. 挂载 overlay 分区：iStoreOS 系统可跳过这一步，LEDE 系统进入 `系统` - `挂载点` 页面点击 `生成配置`，下拉到挂载点部分找到对应设备 `/dev/mmcblk1p3` 点击右侧的 `修改` 按钮。在弹出页面中确认启用已勾选，挂载点选择 `作为外部 overlay 使用 （/overlay)` 保存。返回到 `挂载点` 页面去掉原本 overlay 分区（通常在第一行）的已启用勾选，接着下拉到底部点击 `保存并应用` 按钮。重启系统生效。

3. 挂载 docker 分区：挂载 docker 分区步骤与 overlay 挂载类似，进入 `系统` - `挂载点` 页面点击 `生成配置`，下拉到挂载点部分找到对应设备 `/dev/mmcblk1p4` 点击右侧的 `修改` 按钮。在弹出窗口中确认启用已勾选，挂载点选择 `作为 Docker 数据分区（/opt)` 保存 ( 如果没有该选项就自定义输入 `/opt` )。返回到 `挂载点` 页面下拉到底部点击 `保存并应用` 按钮。重启系统生效。

4. 更新系统：进入 `系统` - `备份与升级` 页面，在 `刷写新的固件` 部分按提示操作即可。

> [!IMPORTANT]
> - **overlay 及 docker 分区的挂载操作建议在修改系统设置前执行。如果修改系统后再修改挂载点，须先把原来分区的文件全部复制到目标分区，操作相对复杂。**
> - 更新系统需要先将固件文件解压为 `.img.gz` 格式再上传，否则系统无法识别。
> - 使用过程中 docker 容器中的目录如需映射到 EMMC 务必映射到 `/opt` 目录。
