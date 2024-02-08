## OpenWrt 23.05 固件 sing-box 使用文档

sing-box 作为一款最近几年出现的通用代理平台拥有和 clash 相当的灵活性和更好的运行效率。但目前 Openwrt 及其衍生路由系统中使用 sing-box 核心的插件中，passwall 仅仅将其用作解析代理协议，而 homeproxy 功能又过于简陋完全没有发挥出 sing-box 核心的特点和优势。于是就有了使用纯 sing-box 核心配合 clash 面板作为代理插件使用的想法，但没有 luci 也导致这样的玩法在配置的便捷性上有所不足，使用上有一定的门槛 (😭 我也不会写 luci 啊)。这样的玩法能够实现完全归功于 [How to Bypass on OpenWRT using Sing-box](https://github.com/rezconf/Sing-box/wiki/How-to-Run) 这篇文档提供的方案。该方案中的服务脚本，网络接口，防火墙设置我已经预先编译进固件中，本文记录了具体的使用方法，想要尝试的小伙伴务必仔细阅读本文。如果使用中有任何问题或者建议欢迎通过 telegram, gmail, issues 与我联系。

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
    "external_ui": "ui",
    "secret": "ffuqiangg",
    "external_ui_download_url": "https://mirror.ghproxy.com/https://github.com/MetaCubeX/Yacd-meta/archive/gh-pages.zip",
    "external_ui_download_detour": "direct",
    "default_mode": "rule"
},
```

仔细阅读下面的说明后将你配置文件中的 clash_api 部分与上面的示例进行对比，按需求修改。 
- **external_controller** 影响 clash 面板的访问地址，大部分机场提供的配置该值为 "127.0.0.1:9090"。`作为 网关/路由 使用地址必须修改为 0.0.0.0`，后面的端口可随意设置只要不与系统本身及其它插件冲突即可。面板访问地址为 `http://路由IP:这里设置的端口/ui`
- **external_ui** clash 面板源码目录，可随意设置，多个配置文件中使用了不同的面板须设置不同的值。
- **external_ui_download_url** clash 面板静态网页资源的 ZIP 下载地址，当 external_ui 设置的目录不存在或是空目录时会从此设置的下载地址下载面板文件。实例为 yacd 面板设置，要使用 metacubexd 面板修改为 "https://mirror.ghproxy.com/https://github.com/MetaCubeX/metacubexd/archive/gh-pages.zip" `此项可省略，省略后默认使用 yacd 面板`
- **external_ui_download_detour** 用于下载静态网页资源的出站的标签。如果为空，将使用默认出站。`此项可省略`
- **secret** clash 面板的登录密码。`网关/路由 使用推荐始终设置一个密码`
- **efault_mode** Clash 中的默认模式，默认使用 Rule。此设置没有直接影响，但可以通过 clash_mode 规则项在路由和 DNS 规则中使用。`此项可省略`

> [!TIP]
> 注意：根据 json 文件语法，最后一项设置的行尾不能有 , 逗号。

按照上面的说明修改好配置文件后复制配置文件为 config.json 就完成了配置文件的准备工作。执行下面的命令即可启动 sing-box。

```bash
cp /etc/sing-box/xxx.json /etc/sing-box/config.json
/etc/init.d/sing-box start
```

### 更新订阅

更新订阅需要前往 OpenWrt 的 `计划任务` 页面或者编辑 `/etc/crontabs/root` 文件手动添加计划任务，如果配置文件需要修改可用 sed 命令实现。可以趁此机会学习一点 linux 知识也是不错的。

```bash
# 这每天 6:00 下载配置文件完成修改，替换 config.json 并重新读取
0 6 * * * wget -O /etc/sing-box/test.json -U "sing-box" "订阅地址" && sed -i 's/127.0.0.1:9090/0.0.0.0:9900/' /etc/sing-box/test.json && cp -f /etc/sing-box/test.json /etc/sing-box/config.json && /etc/init.d/sing-box reload
```

> [!TIP]
> config.json 如有变动须执行 /etc/init.d/sing-box reload 重新读取配置文件方可生效。
