## mihomo 文档

写了一个简单的 mihomo 核心启动器，不涉及任何防火墙操作所以只能使用 tun 模式，支持 mihomo 核心的所有特性。

### 一键安装

```bash
sh -c "$(curl -ksS https://fastly.jsdelivr.net/gh/ffuqiangg/build_openwrt@main/patch/mihomo/install.sh)"
```
配置文件位于 /etc/mihomo/config.yaml

> 此命令使用的配置文件基于 [mihomo 快捷配置](https://wiki.metacubex.one/example/conf/#__tabbed_1_2) 修改优化。源文件在 [这里](https://github.com/ffuqiangg/build_openwrt/tree/main/patch/mihomo/config.yaml) 。

### 使用基础

| 作用 | 终端命令 | 启动项按钮 |
| :--- | :--- | :--- |
| 启用服务（开机自启） | `/etc/init.d/mihomo enable` | <kbd>已禁用</kbd> |
| 禁用服务（关闭自启） | `/etc/init.d/mihomo disable` | <kbd>启用</kbd> |
| 启动服务 | `/etc/init.d/mihomo start` | <kbd>启动</kbd> |
| 停止服务 | `/etc/init.d/mihomo stop` | <kbd>停止</kbd> |
| 重启服务 | `/etc/init.d/mihomo restart` | <kbd>重启</kbd> |

### 配置文件说明

```yaml
proxy-providers:
  provider1: # 订阅名称，可自定义
    url: "" # 订阅地址
    type: http
    interval: 28800 # 自动更新订阅间隔时间，单位秒
    health-check: {enable: true,url: "https://www.gstatic.com/generate_204",interval: 300}
    override:
      additional-prefix: "[provider1] " # 节点名称前缀，多个订阅时方便区分节点来源

# 按下面的设置 Web 面板登录地址：路由IP:9090/ui
external-controller: 0.0.0.0:9090 # Web 面板监听地址，路由器/网关使用必须设置为 0.0.0.0
external-ui: ui # Web 面板文件目录，影响面板登录地址
external-ui-url: "https://gh-proxy.com/github.com/Zephyruso/zashboard/releases/latest/download/dist.zip" # Web 面板源文件下载地址

# 用于 p2p 连接，使用时 p2p 软件设置代理类型：SOCKS5 ，IP：路由IP，端口：10808 。
listeners:
  - name: socks5-in-1
    type: socks
    port: 10808
    listen: 0.0.0.0
    udp: true
    users: []
    proxy: 直连
```

如需进行更加细致的调整请自行阅读 [mihomo 官方文档](https://wiki.metacubex.one/config/)
