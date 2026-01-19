- **此固件仅作测试使用，可能存在各种不确定的 bug ，请谨慎下载。**
- 默认 IP：192.168.1.99 | 默认密码：password
===cutline===
### 基础信息
- 默认 IP：192.168.1.99 | 默认密码：password
- sing-box 裸核相关脚本文件安装使用方法见 ⌈ [sing-box 安装使用文档](https://github.com/ffuqiangg/build_openwrt/blob/main/doc/sing-box_new.md) ⌋
- packages.zip 压缩包内为 komd ipk 文件，LEDE 及 iStoreOS 固件可通过如下命令部署到本地源（占用存储空间 < 20MiB）：
```bash
sh -c "$(curl -ksS https://testingcf.jsdelivr.net/gh/ffuqiangg/build_openwrt@main/files/local_feeds.sh)"
```

|插件差异 |PassWall |OpenClash |V2rayA |HomeProxy |Nikki |Momo |DAED |
|:--- |:---: |:---: |:---: |:---: |:---: |:---: |:---: |
|ImmortalWrt-18.06 |⭕ |⭕ |⭕ |❌ |❌ |❌ |❌ |
|ImmortalWrt-24.10 |⭕ |❌ |⭕ |⭕ |⭕ |⭕ |⭕ |
|Openwrt-24.10 |⭕ |❌ |⭕ |⭕ |⭕ |⭕ |⭕ |
|LEDE |⭕ |❌ |⭕ |⭕ |⭕ |⭕ |⭕ |
|iStoreOS-22.03 |⭕ |⭕ |⭕ |❌ |❌ |❌ |❌ |

`注：ImmortalWrt-18.06 固件不包含 sing-box 核心。`

##

### 更新信息
- 增加 docker 启动限制，只有在 dockerman 配置页面开启 `自动启动` 时才能启动。
- 优化 uhttpd，提升 LuCI 页面响应及加载速度。
- iStoreOS 固件中的 iStore 插件 LuCI 页面修改为二级菜单移动至 `服务` 下。