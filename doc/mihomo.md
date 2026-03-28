## Mihomo 核心轻量化启动器说明文档

这是一个专为 Mihomo 核心设计的启动脚本。由于不涉及复杂的防火墙链改动，该启动器强制使用 TUN 模式，旨在提供最纯粹、完整的 Mihomo 特性支持。

### 🚀 一键安装

```bash
sh -c "$(curl -ksS https://fastly.jsdelivr.net/gh/ffuqiangg/build_openwrt@dev/patch/mihomo/install.sh)"
```

### ⚙️ 配置指南

- 快捷上手： 直接编辑配置文件中的 `proxy-providers` 部分，填入你的订阅地址即可。
- 文件路径： `/etc/mihomo/config.yalml`
- 默认控制台： `http://路由器IP:9090/ui` （默认无密码）
- 参考资料： 本配置基于 ⌈ [mihomo 快捷配置](https://wiki.metacubex.one/example/conf/#__tabbed_1_2) ⌋ 优化；如需深度定制，请参考 ⌈ [mihomo 官方文档](https://wiki.metacubex.one) ⌋ 。

> [!IMPORTANT]
> **自定义配置时的硬性要求：**
> 1. `external-controller` 监听 IP 必须设置为 `0.0.0.0`。
> 2. `allow-lan` 必须设置为 `true`，否则局域网设备无法分流。

### 🛠️ 服务管理
你可以通过命令行或系统启动项页面进行操作：

| 目标效果 | 终端命令 | 启动项管理 (LuCI) |
| :--- | :--- | :--- |
| 开机自启 | `/etc/init.d/mihomo enable` | 点击 <kbd>已禁用</kbd> |
| 禁止自启 | `/etc/init.d/mihomo disable` | 点击 <kbd>启用</kbd> |
| 启动服务 | `/etc/init.d/mihomo start` | 点击 <kbd>启动</kbd> |
| 停止服务 | `/etc/init.d/mihomo stop` | 点击 <kbd>停止</kbd> |
| 重启服务 | `/etc/init.d/mihomo restart` | 点击 <kbd>重启</kbd> |

##

### 📝 配置文件关键字段说明

1. **订阅服务 (Proxy Providers)**
通过 `proxy-providers` 可以实现多订阅管理：
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
- `provider1` / `provider2`：订阅标识，请确保唯一（建议不要与策略组同名）。
- `url`：你的订阅链接。
- `interval`：自动更新频率（单位：秒）。
- `additional-prefix`：为该订阅的节点统一添加前缀，方便区分不同机场。

2. **外部控制 (External Control)**
```yaml
external-controller: 0.0.0.0:9090
external-ui-url: "https://gh-proxy.com/github.com/Zephyruso/zashboard/releases/latest/download/dist.zip"
secret: ""
```
- `external-controller`：外部监听地址。在路由器环境请务必保持 `0.0.0.0:9090`。
- `external-ui-url`：Web 面板（如 Zashboard）的远程下载地址。
- `secret`：面板登录密码，默认为空，建议手动设置。

3. **P2P 优化 (Listeners)**
针对 P2P 软件（如 BitTorrent）的特殊监听：
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
- SOCKS5 代理：默认端口 `10808` 。
- 使用方法：在 P2P 软件中设置代理类型为 `SOCKS5`，地址为 `路由器 IP`，端口为 `10808` 。

##

**想了解更多细节？**  
建议访问 ⌈ [mihomo 配置详解](https://wiki.metacubex.one/config/) ⌋ 进阶学习。