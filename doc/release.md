**测试固件随时删除，谨慎下载使用**
- 默认 IP：192.168.1.99 | 默认密码：password
===cutline===
- 默认 IP：192.168.1.99 | 默认密码：password
- OpenWrt-24.10 及 ImmortalWrt-24.10 固件系统分区由 23.05 固件的 720M 调整为 820M 。
- sing-box 裸核相关脚本文件安装使用方法见 ⌈ [sing-box 安装使用文档](https://github.com/ffuqiangg/build_openwrt/blob/main/doc/sing-box_new.md) ⌋
- LEDE，iStoreOS 部署本地 kmod 源命令：
```bash
sh -c "$(curl -ksS https://testingcf.jsdelivr.net/gh/ffuqiangg/build_openwrt@main/files/local_feeds.sh)"
```

|插件差异          |PassWall |OpenClash |V2rayA |HomeProxy |Nikki |DAED |
|:---              |:---:    |:---:     |:---:  |:---:     |:---: |:---:|
|ImmortalWrt-18.06 |⭕       |⭕        |⭕     |❌        |❌    |❌   |
|ImmortalWrt-24.10 |⭕       |❌        |⭕     |⭕        |⭕    |⭕   |
|Openwrt-24.10     |⭕       |❌        |⭕     |⭕        |⭕    |⭕   |
|LEDE              |⭕       |❌        |⭕     |⭕        |⭕    |⭕   |
|iStoreOS-22.03    |⭕       |⭕        |⭕     |❌        |❌    |❌   |

`注：ImmortalWrt-18.06 固件不包含 sing-box 核心。`