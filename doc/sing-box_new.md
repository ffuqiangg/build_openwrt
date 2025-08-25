## sing-box 安装使用文档

重新写了一个 sing-box 服务。使用 redirect(tcp) + tproxy(udp) 代理，fw3、fw4 都可以使用，支持自动下载订阅，自动重启更新订阅，修复了老方法 docker bridge 网络的联网问题，一些配置参数可自定义，支持调整 DNS 及路由分流规则等，仅支持 ipv4，不支持 ipv6 。

本项目不具备订阅转换功能，如果机场没有提供 sing-box 订阅可以使用转换服务。仓库的 [另一篇文档](sing-box-subscribe.md) 中有使用 sing-box-subscribe 配合本项目使用的一些简单介绍。

**更新记录**  
- **2025.02.06** 更新支持多订阅，并新增跳过中国大陆 IP 和仅代理常用端口功能。
- **2025.02.09** 修复了一些错误。另外：现在的版本仅支持 sing-box 1.10.x 版本，后续会支持 1.11.x 版本。
- **2025.02.10** 修复 fw3 上仅代理常用端口错误。
- **2025.02.14** 优化代码，新增新的本地文件运行方式和缓存 fakeip 开关。
- **2025.02.14-A** 更新至 sing-box 1.11.x 版本，不再支持 sing-box 1.10.x ，可以通过 `PassWall -> 组件更新` 页面查看和更新 sing-box 版本。使用中有任何问可**到仓库提 Issues 。
- **2025.02.22** 修复多网口设备获取子网地址错误及其它一些小错误，新增 mixed 代理端口设置。
- **2025.02.24** 新增 Web 面板选择，可选 MetaCubeXD，Zashboard，YACD 。
- **2025.04.01** 使用脚本语言 ucode 重构了大部分代码，不再依赖 jq ，但需要固件具备 ucode 支持。更新调整常用端口具体配置，修复仅代理常用端口时 mixed 代失效的问题，取消本地 -1 运行方式，新增屏蔽 quic 开关、缓存 rdrc 开关，优化了防火墙规则，使用独立 DNS 入站端口避免 sing-box 核心不能正确劫持 DNS 请。jq** 版本仍可正常安装使用，且同步本次更新，但后续不再维护。
- **2025.04.04** 修复某些特定情况下无法正常下载 rule_set 规则集导致服务启动失败：自动为规则集 url 为 github.com 和 githubusercontent.com 的地址添加 gi**hub 代理并使用直连下载。
- **2025.04.08** 优化 DNS 转发，`网络 -> DHCP/DNS -> DNS 重定向` 选项开启时使用 DNSMASQ 转发 DNS ，未开启或没有此项则使用防火墙转发 DNS 。
- **2025.04.20** 优化防火墙规则，代理方式调整为 redirect(tcp) + tproxy(udp) 。
- **2025.04.25** 调整 mixed 代理默认监听端口。
- **2025.05.04** 新增日志输出方式（ 面板 / 文件 ）选项。
- **2025.05.05** 删除缓存 fakeip 设置，改为检测到配置文件启用 fakeip 自动开启。
- **2025.05.10** 原模板功升级为混入功能，可动态调整 DNS 和路由分流规则，还包含可手动开启的去广告功能。
- **2025.05.25** 调整了配置文件的默认处理逻辑，新版本默认会提取节点然后按 config 设置本地生成新的配置文件使用（默认生成不带去广告的大陆白名单模式配置）。如果不希望脚本对原始配置文件做过多调整可以禁用 `advanced -> override` ，此时除了必要的部分外不会对配置文件做其他修改。新版本重新整理了 config 设置文件并新增 DNS、去广告、节点过滤，节点区域分组，路由规则分流设置。
- **2025.06.10** 调整自用功能，合并 custom, direct, proxy 文件并改用 json 格式。
- **2025.06.12** 调整节点分组策略，使用分流或 cutom.json 时不再强制开启节点分组。完全交由 `group_nodes` 开关控制。
- **2025.08.05** 更新至 sing-box 1.12.x 版本。

### 安装命令

ucode 版本安装命令（推荐使用）
```bash
sh -c "$(curl -ksS https://fastly.jsdelivr.net/gh/ffuqiangg/build_openwrt@main/patch/sing-box/ucode/install.sh)"
```
jq 版本安装命令（2025.04.01 后停止维护）
```bash
sh -c "$(curl -ksS https://fastly.jsdelivr.net/gh/ffuqiangg/build_openwrt@main/patch/sing-box/jq/install.sh)"
```

- 注意本命令安装时会清空 /etc/sing-box 目录并初始化 /etc/config/sing-box 文件，如有需要请提前备份数据。
- 本仓库最新固件除 ImmortalWrt-18.06 不含 sing-box 核心之外都可使用 ucode 版本，其它固件自行检查安装依赖项 ucode , ucode-mod-uci , ucode-mod-fs 。
- 日志文件时间戳如果出现时区错误，可通过安装 zoneinfo-asia (重启系统生效) 解决，本仓库最新固件已默认编译。

### 使用基础

- `/etc/init.d/sing-box enable` 启用服务 = 开机自启
- `/etc/init.d/sing-box disable` 禁用服务 = 关闭开机自启
- `/etc/init.d/sing-box start` 启动服务
- `/etc/init.d/sing-box stop` 停止服务
- `/etc/init.d/sing-box restart` 重启服务

以上命令分别对应 `启动项` 页面 `sing-box` 一行的 `已禁用`，`已启用`，`启动`，`停止`，`重启` 按钮。

### 配置服务

所有的配置选项都通过修改 /etc/config/sing-box 文件实现，下面分几个部分说明其各个选项的作用。文末有分别使用订阅链接和本地配置文件的 [最小配置](#最小配置) 实例。  

1. **基本设置**
```config
config sing-box 'main'
	option enabled '0'                          # 总开关，设为 1 服务才能运行
	option conffile '/etc/sing-box/config.json'
	option workdir '/etc/sing-box'
```
- conffile 为配置文件路径、workdir 为服务运行目录，不要修改否则运行会出错。

2. **配置文件和订阅相关** `2025.04.01 更新 取消本地 -1 运行方式`
```config
config sing-box 'subscription'
	option remote '1'                           # 使用订阅还是本地配置，0 本地配置文件，1 订阅1，2 订阅2 ...
	list url ''                                 # 订阅链接 1
	list url ''                                 # 订阅链接 2
	option auto_restart '1'                     # 定时重启，0 禁用，1 启用
	option restart_cron '0 5 * * *'             # 定时重启 cron，默认为每天早上 5 点
```
- 本地配置文件保存到 /etc/sing-box 目录命名为 sing-box.json 。
- 使用订阅时服务启动会自动下载所有订阅，所以定时重启也能起到更新订阅的作用。
- 如果有更多订阅，配置中新建更多 `list url` 项目即可。

3. **代理相关** `2025.04.01 更新 增加屏蔽 quic 功能`
```config
config sing-box 'proxy'
	option common_ports '0'                     # 仅代理常用端口，0 否，1 是
	option pass_cn_ip '0'                       # 跳过中国大陆 IP，0 否，1 是
	option fuck_quic '0'                        # 屏蔽 quic，0 否，1 是
```
- 使用 p2p 下载可开启仅代理常用端口，避免 p2p 流量进入 sing-box 核心。

4. **基础配置** `2025.05.25 更新 整理合并设置条目，调整默认面板`
```config
config sing-box 'basic'
	option level 'warn'                         # 日志等级
	option log_file '0'                         # 日志输出方式，0 输出到面板，1 输出到文件
	option output '/var/log/sing-box.log'       # 日志文件路径（log_file 为 0 时此项无效）
	option external_controller_port '9900'      # 后台页面端口
	option external_ui 'ui'                     # 面板文件目录
	option secret 'ffuqiangg'                   # 后台页面登陆密钥
	option ui_name 'zashboard'                  # Web 面板，可选值 metacubexd / zashboard / yacd
	option default_mode 'rule'                  # clash 默认模式
	option store_rdrc '0'                       # 缓存 rdrc，0 禁用，1 启用
	option tproxy_port '10105'                  # tproxy 监听端口
	option mixed_port '2881'                    # mixed 代理端口
	option dns_port '2053'                      # DNS 入站端口 (direct)
	option redirect_port '2331'                 # redirect 监听端口
```
- 按照默认设置面板登录地址为 `设备IP:9900/ui`，密钥 `ffuqiangg` 。
- 这部分配置的详细说明可以查看 sing-box [官方配置文档](https://sing-box.sagernet.org/zh/configuration/) 的对应条目。
- 如需修改端口选项要注意端口冲突，避免使用已占用的端口。
- mixed 代理提供 socks4, socks4a, socks5 和 http 代理服务（注意 mixed 仅代理 tcp 流量）。
- 更新或替换面板方法：删除 `/etc/sing-box/ui` 目录，然后重启 sing-box 服务。

5. **高级设置** `2025.06.12 更新 调整节点分组策略`
```config
config sing-box 'advanced'
	option override '1'                                              # 覆写，0 禁用，1 启用
	option main_dns_type 'https'                                     # 国外 DNS 类型
	option main_dns_server 'dns.google'                              # 国外 DNS 服务地址
	option china_dns_type 'h3'                                       # 国内 DNS 类型
	option china_dns_server '223.5.5.5'                              # 国内 DNS 服务地址，必须使用 IP 形式
	option adblock '0'                                               # 去广告，0 禁用，1 启用
	list ad_ruleset 'https://testingcf.jsdelivr.net/gh/ffuqiangg/sing-box-adsruleset@main/rule/adguard-dns-filter.srs'
	list ad_ruleset ''                                               # 去广告规则集，必须使用 srs 格式且地址可直连
	option filter_nodes '0'                                          # 过滤节点，0 禁用，1 启用
	option filter_keywords '流量,套餐,重置,官網,官网,群组'             # 过滤关键字，多个关键字用英文逗号分割
	option group_nodes '0'                                           # 节点按区域分组，0 禁用，1 启用
	option stream '0'                                                # 路由分流规则，0 禁用，1 启用
	option stream_list 'Google,Github,Telegram,OpenAI,Spotify'       # 启用的分流规则，英文逗号分割
```
- `override` 覆写是高级设置的总开关，默认情况下会生成不带去广告的大陆白名单模式配置文件。
- 禁用 `override` 时所有高级设置均不会生效，除了 `基础设置` 涉及的部分外不会对配置文件做其他修改。禁用 `override` 时请确保配置文件符合当前 sing-box 版本的要求。
- 去广告功能可以同时使用多个规则集，自行添加更多的 `list ad_ruleset` 条目即可，规则集要求使用 srs 格式且地址可直连。多个规则集注意文件名不能相同。
- `filter_nodes` 过滤的节点会从配置文件中完全去除，而不仅仅是不出现在分组中。
- `gourp_nodes` 可用的分组区域包含香港、台湾、日本、韩国、新加坡、美国、德国。订阅中没有的节点区域会自动跳过不会生成空分组。添加区域可按格式修改 `/etc/sing-box/resources/stream.json` 文件，参考 [STREAM 分流文档](stream.md) 。
- `stream_list` 脚本预置的可使用分流规则有 Google，Github，Telegram，OpenAI，DMM，HBO，NETFLIX，Spotify 。添加分流规则可按格式修改 `/etc/sing-box/resources/stream.json` 文件，参考 [STREAM 分流文档](stream.md) 。

6. **私货** `自用功能，运行结果不符合预期概不负责`
- 仅在 `override` 开启时生效。用于自定义域名分流和强制域名直连 / 代理。
- 在 `/etc/sing-box/resources` 目录新建 custom.json 文件。其 `TOP` 对象键为出站分组 / 节点（如果分组不存在则自动创建），值为一组无头规则。示例文件 [custom.json](https://gist.github.com/ffuqiangg/00a6acb48a1fb9f60a424e606e7a930a) ，语法参考 [无头规则](https://sing-box.sagernet.org/zh/configuration/rule-set/headless-rule/) 。

### 最小配置

面板登录地址：`设备IP:9900/ui`，密钥：`ffuqiangg` 。

1. **使用订阅** 修改如下选项
```config
config sing-box 'main'
	option enabled '1'

config sing-box 'subscription'
	option url '订阅地址'
```

2. **使用本地配置文件** 将配置文件放到 /etc/sing-box 目录命名为 sing-box.json，并修改如下选项
```config
config sing-box 'main'
	option enabled '1'

config sing-box 'subscription'
	option remote '0'
```

##

使用中有疑问可以通过 [Gmail](mailto:ffuiangg@gmail.com) 或 [Telegram](https://t.me/ffuqiangg) 联系我，发现代码有问题或者其它改进意见欢迎提交 PR / Issues 。