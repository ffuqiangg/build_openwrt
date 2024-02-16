## OpenWrt 23.05 固件 sing-box 使用文档

sing-box 作为通用代理平台拥有和 clash 相当的灵活性和更好的运行效率。但目前 Openwrt 及其衍生路由系统中使用 sing-box 核心的插件中，passwall 仅仅将其用作解析代理协议，而 homeproxy 设计简洁无法完全发挥出 sing-box 核心的特点和优势。于是就有了使用纯 sing-box 核心配合 clash 面板作为代理插件使用的想法，本文记录了具体的使用方法，想要尝试的小伙伴务必仔细阅读本文。如果使用中有任何问题或者建议欢迎通过 telegram, gmail, issues 与我联系。

### 基础命令

```bash
/etc/init.d/sing-box enable
```
启用 sing-box 服务，作用等效于开启 sing-box 开机自启。固件为了避免和其它代理插件冲突默认禁用 sing-box 服务，使用 sing-box 前请先用此命令启用 sing-box 服务。

```bash
/etc/init.d/sing-box disable
```
禁用 sing-box 服务，作用为关闭 sing-box 开机自启。在你尝试过 sing-box 后要切换到其它代理插件时应使用此命令禁用 sing-box 服务，避免机器重启后 sing-box 自动启动造成两个代理插件同时运行发生冲突。

```bash
/etc/init.d/sing-box start
```
启动 sing-box，配置文件准备好后使用此命令启动 sing-box。

```bash
/etc/init.d/sing-box stop
```
关闭 sing-box，停止 sing-box 运行。

```bash
/etc/init.d/sing-box reload
```
重新读取配置文件，当 sing-box 正在运行过程中配置文件发生变化时使用此命令重新读取配置文件。

### 准备配置文件

如果你的机场提供了 sing-box 订阅链接直接将配置文件下载到 /etc/sing-box 目录。如果机场没有提供 sing-box 订阅 google 搜索 sing-box 订阅转换服务。

```bash
cd /etc/sing-box
wget -U "sing-box" "订阅地址" -O xxx.json
```

> [!TIP]
> 可以保存多个订阅的配置文件，注意从文件名进行区分。sing-box 运行时只会读取 config.json ，所以要使用的配置文件修改好后须重命名或者复制一份为 config.json 。

然后需要视情况对配置文件进行一些修改。

```json
"clash_api":{ 
    "external_controller": "0.0.0.0:9900",
    "external_ui": "yacd",
    "secret": "ffuqiangg",
    "external_ui_download_url": "https://mirror.ghproxy.com/https://github.com/MetaCubeX/Yacd-meta/archive/gh-pages.zip",
    "external_ui_download_detour": "direct",
    "default_mode": "rule"
},
```

仔细阅读下面的说明后将你配置文件中的 clash_api 部分与上面的示例进行对比，按需求修改。 
- **external_controller** 影响 clash 面板的访问地址，大部分机场提供的配置该值为 "127.0.0.1:9090"。`作为 网关/路由 使用地址必须修改为 0.0.0.0`，后面的端口可随意设置只要不与系统本身及其它插件冲突即可。面板访问地址为 `http://路由IP:这里设置的端口/ui`
- **external_ui** clash 面板源码目录，可随意设置，多个配置文件中使用了不同的面板须设置不同的值。
- **external_ui_download_url** clash 面板静态网页资源的 ZIP 下载地址，当 external_ui 设置的目录不存在或是空目录会按这里设置的地址下载面板文件。实例为 yacd 面板，要使用 metacubexd 面板修改为 "https://mirror.ghproxy.com/https://github.com/MetaCubeX/metacubexd/archive/gh-pages.zip" `此项可省略，省略后默认使用 yacd 面板`
- **external_ui_download_detour** 用于下载静态网页资源的出站的标签。如果为空，将使用默认出站。`此项可省略`
- **secret** clash 面板的登录密码。`网关/路由 使用推荐始终设置一个密码`
- **default_mode** Clash 中的默认模式，默认使用 Rule。此设置没有直接影响，但可以通过 clash_mode 规则项在路由和 DNS 规则中使用。`此项可省略`

```json
{
    "type": "tproxy",
    "tag": "tproxy-in",
    "listen": "::",
    "listen_port": 10105,
    "tcp_fast_open": true,
    "udp_fragment": true,
    "sniff": true
},
```

找到配置文件中的 inbounds 部分对照上方的示例然后将其中包含 `"type": "tun"` 的整个 {} 中的内容替换为上面的示例代码。这步的作用是将代理模式由 tun 换为 tproxy，想使用 tun 模式的小伙伴可忽略这一步修改，然后根据 [参考文档](https://github.com/ffuqiangg/build_openwrt/blob/main/docs/sing-box.md#参考文档) 1 的方法手动添加网络接口和防火墙区域。[^1]  
- **listen_port** 参数要修改必须同步修改 /etc/sing-box/nftables.rules 文件中的端口部分。文件对应的仓库源码为 patch/sing-box/files/nftables.rules

[^1]: 在我的测试中 tun 模式会严重影响直连性能，不知道是不是我的姿势不对。

> [!CAUTION]
> 注意：根据 json 文件语法，最后一项设置的行尾不能有 , 逗号。

按照上面的说明修改好配置文件后复制配置文件为 config.json 就完成了配置文件的准备工作。执行下面的命令即可启动 sing-box。

```bash
cp /etc/sing-box/xxx.json /etc/sing-box/config.json
/etc/init.d/sing-box start
```

> [!NOTE]
> 固件中提供了一个模板可以方便的使用上面的示例快速修改配置文件。使用方法参考 [更新订阅](https://github.com/ffuqiangg/build_openwrt/blob/main/docs/sing-box.md#更新订阅) 中的示例部分。

### 更新订阅

更新订阅需要前往 OpenWrt 的 `计划任务` 页面或者编辑 `/etc/crontabs/root` 文件手动添加计划任务，如果配置文件需要修改可用 sed 命令实现。可以趁此机会学习一点 linux 知识也是不错的。

```bash
# 这每天 6:00 下载并自动启用模板文件修改配置文件覆盖 config.json，然后重新读取配置文件。( xxx.json 为机场提供的原始状态未修改 ）
0 6 * * * wget -O /etc/sing-box/xxx.json -U "sing-box" "订阅地址" && jq -s add /etc/sing-box/xxx.json /etc/sing-box/template.json > config.json && /etc/init.d/sing-box reload
# 作用与上面相同但不覆盖 config.json，而是保存为 xxx.json
0 6 * * * wget -O /etc/sing-box/xxx.json -U "sing-box" "订阅地址" && jq -s add /etc/sing-box/xxx.json /etc/sing-box/template.json > tmp && mv /etc/sing-box/tmp /etc/sing-box/xxx.json
```

> [!TIP]
> config.json 如有变动须执行 /etc/init.d/sing-box reload 重新读取配置文件方可生效。

### 参考文档

1. [How to Bypass on OpenWRT using Sing-box](https://github.com/rezconf/Sing-box/wiki/How-to-Run)

2. [sing-box 透明代理笔记](https://idev.dev/proxy/sing-box-tproxy.html)

3. [TProxy 透明代理配置教程](https://xtls.github.io/document/level-2/tproxy_ipv4_and_ipv6.html)
