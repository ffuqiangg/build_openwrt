## Mihomo 核心轻量化启动器说明文档

这是一个专为 Mihomo 核心设计的启动脚本。由于不涉及复杂的防火墙链改动，该启动器强制使用 TUN 模式，旨在提供最纯粹、完整的 Mihomo 特性支持。

### 🚀 一键安装

```bash
sh -c "$(curl -ksS https://fastly.jsdelivr.net/gh/ffuqiangg/build_openwrt@main/patch/mihomo/install.sh)"
```

### ⚙️ 配置指南

- 快捷上手 : 直接编辑配置文件中的 `proxy-providers` 部分，依照注释填入你的订阅地址即可。
- 文件路径 : `/etc/mihomo/config.yaml`
- 默认控制台 : `http://路由器IP:9090/ui` (密码：ffuqiangg)
- 参考资料 : 本配置基于 ⌈ [mihomo 快捷配置](https://wiki.metacubex.one/example/conf/#__tabbed_1_2) ⌋ 优化；如需深度定制，请参考 ⌈ [mihomo 官方文档](https://wiki.metacubex.one) ⌋ 。

> [!IMPORTANT]
> **自定义配置时的硬性要求：**
> 1. `external-controller` 监听 IP 必须设置为 `0.0.0.0` 。
> 2. `allow-lan` 必须设置为 `true`，否则局域网设备无法分流。

### 🛠️ 服务管理

你可以通过命令行或系统启动项页面进行操作

启用 mihomo 服务
```shell
/etc/init.d/mihomo enable
```
使用以下命令立即启动 mihomo
```shell
/etc/init.d/mihomo start
```
使用以下命令使 mihomo 重新启动
```shell
/etc/init.d/mihomo restart
```
使用以下命令停止运行 mihomo
```shell
/etc/init.d/mihomo stop
```
禁用 mihomo 服务
```shell
/etc/init.d/mihomo disable
```

##

### 📝 配置文件关键字段说明

1. **订阅服务 (Proxy Providers)**

```yaml
proxy-providers:
  provider1:
    url: ""
    type: http
    interval: 28800
    health-check: { enable: true, url: "https://www.gstatic.com/generate_204", interval: 300 }
    override:
      additional-prefix: "[provider1] "
      ip-version: ipv4-prefer
  provider2:
    url: ""
    type: http
    interval: 28800
    health-check: { enable: true, url: "https://www.gstatic.com/generate_204", interval: 300 }
    override:
      additional-prefix: "[provider2] "
      ip-version: ipv4-prefer
```
- `provider1` / `provider2` : 订阅标识，请确保唯一 (建议不要与策略组同名)
- `url` : 你的订阅链接
- `interval` : 自动更新频率 (单位: 秒)
- `additional-prefix` : 多个订阅自动合并，前缀自动添加到对应节点名称

2. **P2P 优化 (Listeners)**

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
- 配置文件内置 SOCKS5 监听直连接口，P2P 软件中设置代理类型: SOCKS5，IP: 路由器IP，端口: 10808

```yaml
rules:
  - NOT,((DST-PORT,22/53/80/143/443/465/587/853/873/993/995/5222/8080/8443/9418)),直连

```
- P2P 软件不支持 SOCKS5 代理时将以上规则加入到配置文件 `rules` 第一行，即可实现非常用端口直连

3. **分流规则 (Rules)**

分流规则示意图

```yaml
proxy-groups:
  - name: 新加坡
    type: select
    include-all: true
    exclude-type: direct
    filter: "(?i)(新|sg|singapore)"
    icon: "https://gh-proxy.com/raw.githubusercontent.com/ffuqiangg/icon/main/svg/Singapore.svg"
                             |
  - name: Telegram           ▼
    type: select           ~~~~~
    proxies: [默认,香港,日本,新加坡,美国,其它地区,全部节点,自动选择,直连]
    icon: "https://gh-proxy.com/raw.githubusercontent.com/ffuqiangg/icon/main/svg/Telegram.svg"
                                |
                                ▼
rules:                       ~~~~~~~~   
  - RULE-SET,telegram_domain,Telegram
             ~~~~~~~~~~~~~~~
                    ▲
                    |
rule-providers:
  telegram_domain:
    type: http
    interval: 86400
    behavior: domain
    format: mrs
    url: "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/telegram.mrs"
```

##

**想了解更多细节？**  
建议访问 ⌈ [mihomo 配置详解](https://wiki.metacubex.one/config/) ⌋ 进阶学习。
