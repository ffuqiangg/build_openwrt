## mihomo 文档

写了一个简单的 mihomo 核心启动器，不涉及任何防火墙操作所以只能使用 tun 模式，支持 mihomo 核心的所有特性。

### 一键安装

```bash
sh -c "$(curl -ksS https://fastly.jsdelivr.net/gh/ffuqiangg/build_openwrt@dev/patch/mihomo/install.sh)"
```

- 偷懒用法按照配置文件中的注释写入订阅地址即可。默认 Web 面板登陆地址：路由IP:9090/ui ，无密码。
- 配置文件位于 /etc/mihomo/config.yaml ，基于 ⌈ [mihomo 快捷配置](https://wiki.metacubex.one/example/conf/#__tabbed_1_2) ⌋ 优化调整。源文件在 [这里](https://github.com/ffuqiangg/build_openwrt/tree/main/patch/mihomo/config.yaml) 。
- 配置文件使用 mihomo 标准配置，自己按照 ⌈ [mihomo 官方文档](https://wiki.metacubex.one) ⌋ 手搓也行。

> [!IMPORTANT]
> 手搓配置文件时要注意 `external-controller` 项监听的 IP 必须设置为 `0.0.0.0` 。

### 使用基础

| 作用 | 终端命令 | 启动项按钮 |
| :--- | :--- | :--- |
| 启用服务（开机自启） | `/etc/init.d/mihomo enable` | <kbd>已禁用</kbd> |
| 禁用服务（关闭自启） | `/etc/init.d/mihomo disable` | <kbd>启用</kbd> |
| 启动服务 | `/etc/init.d/mihomo start` | <kbd>启动</kbd> |
| 停止服务 | `/etc/init.d/mihomo stop` | <kbd>停止</kbd> |
| 重启服务 | `/etc/init.d/mihomo restart` | <kbd>重启</kbd> |

### 配置文件简要说明

```yaml
proxy-providers:
  provider1:
    url: ""
    type: http
    interval: 28800
    health-check: {enable: true,url: "https://www.gstatic.com/generate_204",interval: 300}
    override:
      additional-prefix: "[provider1] "
      ip-version: ipv4-prefer
  provider2:
    url: ""
    type: http
    interval: 28800
    health-check: {enable: true,url: "https://www.gstatic.com/generate_204",interval: 300}
    override:
      additional-prefix: "[provider2] "
      ip-version: ipv4-prefer
```
- `provider1` `provider2` 订阅名称，不能重复，建议不要和策略组名称重复
- `url` 订阅地址
- `interval` 订阅更新间隔时间，单位秒
- `additional-prefix` 为节点名称添加固定前缀，方便多个订阅时区分节点

```yaml
external-controller: 0.0.0.0:9090
external-ui-url: "https://gh-proxy.com/github.com/Zephyruso/zashboard/releases/latest/download/dist.zip"
secret: ""
```
- `external-controller` 外部监听地址，路由器上使用 IP 必须为 0.0.0.0
- `external-ui-url` Web 面板源码下载地址
- `secret` Web 面板登录密码

```yaml
listeners:
  - name: socks5-in-1
    type: socks
    port: 10808
    listen: 0.0.0.0
    udp: true
    users: []
    proxy: 直连
```
- 用于 p2p 连接，使用时 p2p 软件设置代理类型：SOCKS5 ，IP：路由IP，端口：10808

如需进行更加细致的调整请自行阅读 ⌈ [mihomo 官方文档](https://wiki.metacubex.one/config/) ⌋ 。