## sing-box OpenWrt 安装与配置指南

本方案采用 `redirect (TCP)` + `tproxy (UDP)` 代理模式，兼容 **fw3** 与 **fw4**。支持订阅自动更新、分流规则自定义，并解决了 Docker Bridge 网络的联网痛点。

> [!IMPORTANT]
> 仅支持 **IPv4**，不支持 IPv6。本项目不含订阅转换功能，如需转换请参考 [sing-box-subscribe 文档](subscribe.md) 。

<details>
<summary>🕒 点击展开更新日志</summary>

- **2025.12.22** 解除国内 DNS 必须使用 IP 地址的限制。
- **2025.12.08** 支持多订阅环境下仅更新当前使用的订阅。
- **2025.09.08** 整理运行目录。
- **2025.08.05** 更新至 sing-box 1.12.x 版本。
- **2025.06.12** 调整节点分组策略，使用分流或 cutom.json 时不再强制开启节点分组。完全交由 `group_nodes` 开关控制。
- **2025.06.10** 调整自用功能，合并 custom, direct, proxy 文件并改用 json 格式。
- **2025.05.25** 调整了配置文件的默认处理逻辑，新版本默认会提取节点然后按 config 设置本地生成新的配置文件使用（默认生成不带去广告的大陆白名单模式配置）。如果不希望脚本对原始配置文件做过多调整可以禁用 `advanced -> override` ，此时除了必要的部分外不会对配置文件做其他修改。新版本重新整理了 config 设置文件并新增 DNS、去广告、节点过滤，节点区域分组，路由规则分流设置。
- **2025.05.10** 原模板功升级为混入功能，可动态调整 DNS 和路由分流规则，还包含可手动开启的去广告功能。
- **2025.05.05** 删除缓存 fakeip 设置，改为检测到配置文件启用 fakeip 自动开启。
- **2025.05.04** 新增日志输出方式（ 面板 / 文件 ）选项。
- **2025.04.25** 调整 mixed 代理默认监听端口。
- **2025.04.20** 优化防火墙规则，代理方式调整为 redirect(tcp) + tproxy(udp) 。
- **2025.04.08** 优化 DNS 转发，`网络 -> DHCP/DNS -> DNS 重定向` 选项开启时使用 DNSMASQ 转发 DNS ，未开启或没有此项则使用防火墙转发 DNS 。
- **2025.04.04** 修复某些特定情况下无法正常下载 rule_set 规则集导致服务启动失败：自动为规则集 url 为 github.com 和 githubusercontent.com 的地址添加 github 代理并使用直连下载。
- **2025.04.01** 使用脚本语言 ucode 重构了大部分代码，不再依赖 jq ，但需要固件具备 ucode 支持。更新调整常用端口具体配置，修复仅代理常用端口时 mixed 代失效的问题，取消本地 -1 运行方式，新增屏蔽 quic 开关、缓存 rdrc 开关，优化了防火墙规则，使用独立 DNS 入站端口避免 sing-box 核心不能正确劫持 DNS 。jq 版本仍可正常安装使用，且同步本次更新，但后续不再维护。
- **2025.02.24** 新增 Web 面板选择，可选 MetaCubeXD，Zashboard，YACD 。
- **2025.02.22** 修复多网口设备获取子网地址错误及其它一些小错误，新增 mixed 代理端口设置。
- **2025.02.14-A** 更新至 sing-box 1.11.x 版本，不再支持 sing-box 1.10.x ，可以通过 `PassWall -> 组件更新` 页面查看和更新 sing-box 版本。使用中有任何问题可提 Issues 。
- **2025.02.14** 优化代码，新增新的本地文件运行方式和缓存 fakeip 开关。
- **2025.02.10** 修复 fw3 上仅代理常用端口错误。
- **2025.02.09** 修复了一些错误。另外：现在的版本仅支持 sing-box 1.10.x 版本，后续会支持 1.11.x 版本。
- **2025.02.06** 更新支持多订阅，并新增跳过中国大陆 IP 和仅代理常用端口功能。

</details>


### 🚀 安装步骤

推荐使用 **ucode** 版本（需固件支持 `ucode`, `ucode-mod-uci`, `ucode-mod-fs`）。

**ucode 版本（推荐）：**
```bash
sh -c "$(curl -ksS https://fastly.jsdelivr.net/gh/ffuqiangg/build_openwrt@main/patch/sing-box/ucode/install.sh)"
```
**jq 版本（停止维护）：**
```bash
sh -c "$(curl -ksS https://fastly.jsdelivr.net/gh/ffuqiangg/build_openwrt@main/patch/sing-box/jq/install.sh)"
```

> [!WARNING]
> 1. 安装脚本会重置 `/etc/sing-box` 目录及 `/etc/config/sing-box` 配置文件。执行前请务必备份个人数据。
> 2. 安装 `zoneinfo-asia` (重启系统生效) 可解决日志时间戳错误，本仓库最新固件已默认编译。


### 🛠️ 服务管理

你可以通过命令行或系统启动项页面进行操作：

| 目标效果 | 终端命令 | 启动项管理 (LuCI) |
| :--- | :--- | :--- |
| 开机自启 | `/etc/init.d/sing-box enable` | 点击 <kbd>已禁用</kbd> |
| 禁止自启 | `/etc/init.d/sing-box disable` | 点击 <kbd>启用</kbd> |
| 启动服务 | `/etc/init.d/sing-box start` | 点击 <kbd>启动</kbd> |
| 停止服务 | `/etc/init.d/sing-box stop` | 点击 <kbd>停止</kbd> |
| 重启服务 | `/etc/init.d/sing-box restart` | 点击 <kbd>重启</kbd> |

##

### 💡 快速上手 (最小配置)

1. **方案 A：使用订阅链接**
- 修改 `main` 部分：`option enabled '1'`
- 修改 `profile` 部分：`option url '你的订阅地址'`

2. **方案 B：使用本地文件**
- 将 `sing-box.json` 上传至 `/etc/sing-box/profiles/` 目录。
- 修改 `main` 部分：`option enabled '1'`
- 修改 `profile` 部分：`option profile 'file:sing-box.json'`

##

### ⚙️ 核心配置详解

所有配置均通过修改 `/etc/config/sing-box` 实现。

1. **基础设置 (main)**

```config
config sing-box 'main'
	option enabled '0'                          # 总开关，设为 1 脚本才能运行
	option workdir '/etc/sing-box'              # 运行目录
	option fuck_quic '1'                        # 屏蔽 QUIC，0 否，1 是
	option common_ports '0'                     # 仅代理常用端口，0 否，1 是
	option pass_cn_ip '0'                       # 跳过中国大陆 IP，0 否，1 是
```
- `enabled`：核心总开关。
- `common_ports`：开启后仅代理常用端口，可避免 P2P 下载流量进入 sing-box 核心。
- `pass_cn_ip`：开启后直连中国大陆 IP。

2. **配置管理 (profile)**

```config
config sing-box 'profile'
	option profile 'sub:1'                      # 模式切换，可选 sub:NUM ，file:xxx.json ，all
	list prefix '[provider1] '                  # 前缀 1
	list url ''                                 # 订阅链接 1
	list prefix '[provider2] '                  # 前缀 2
	list url ''                                 # 订阅链接 2
	option restart_cron '0 5 * * *'             # 定时重启 cron，留空禁用
```
- `profile`：`sub:NUM` 使用 订阅NUM ，`file:xxx.json` 使用本地配置文件 `/etc/sing-box/profiles/xxx.json` ，`all` 自动合并全部订阅。
- `prefix`：自动添加节点名称前缀，仅 `profile` 设置为 `all` 时生效且必要。
- `restart_cron`：启用可实现定时更新订阅并重启服务。
- 如果有更多订阅，配置中新建更多 `list url` 项目即可。

3. **进阶设置 (basic)**

```config
config sing-box 'basic'
	option log_level 'warn'                     # 日志等级
	option log_file '/var/log/sing-box.log'     # 日志文件路径，留空则日志输出到 Web 面板
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
- `mixed_port`：提供 HTTP/SOCKS 混合代理。
- `dns_port`：DNS 入站端口，用于接管设备 DNS 请求。
- 默认 Web 面板登录地址为 `http://路由器IP:9900/ui`，密钥为 `ffuqiangg`。
- 这部分配置的详细说明可以查看 ⌈ [sing-box 官方文档](https://sing-box.sagernet.org/zh/configuration/) ⌋ 的对应条目。
- 如需修改端口配置要注意端口冲突，避免使用已占用的端口。
- 更新或替换面板方法：删除 `/etc/sing-box/run/ui` 目录，然后重启 sing-box 服务。

4. **高级设置 (advanced)**

```config
config sing-box 'advanced'
	option override '1'                                              # 覆写，0 禁用，1 启用
	option main_dns_type 'https'                                     # 国外 DNS 类型
	option main_dns_server 'dns.google'                              # 国外 DNS 服务地址
	option china_dns_type 'h3'                                       # 国内 DNS 类型
	option china_dns_server '223.5.5.5'                              # 国内 DNS 服务地址
	option ad_ruleset 'https://testingcf.jsdelivr.net/gh/ffuqiangg/sing-box-adsruleset@main/rule/adguard-dns-filter.srs'
	option nodes_filter ''                                           # 排除节点关键字，英文逗号分割。留空禁用
	option area ''                                                   # 节点按地区分组，英文逗号分割。留空禁用
	option bypass ''                                                 # 启用的分流规则，英文逗号分割。留空禁用
```
- `override`：禁用时所有高级设置均不会生效，除了 `进阶设置` 涉及的部分外不会对配置文件做其它修改。
- `ad_ruleset`：去广告规则集下载地址，要求 srs 格式且地址可直连。留空则禁用去广告规则。
- `area`：可选项 - 香港,台湾,日本,韩国,新加坡,美国,德国 。
- `bypass`：可选项 - Gemini,YouTube,Google,MicrosoftCN,Github,Microsoft,Telegram,OpenAI,DMM,NETFLIX,Spotify,Instagram,Apple,AppleCN 。注意前后顺序避免规则失效。
- `area` 及 `bypass` 使用的数据来自 `/etc/sing-box/resources/stream.json` 文件，可按格式自行修改。

5. **私货**

- 自用功能，运行结果不符合预期概不负责。
- 仅在 `override` 开启时生效。用于自定义域名分流和强制域名直连 / 代理。
- 在 `/etc/sing-box/resources` 目录新建 custom.json 文件。其 `top` 对象键为出站分组 / 节点（如果分组不存在则自动创建），值为一组无头规则。示例文件 [custom.json](https://gist.github.com/ffuqiangg/00a6acb48a1fb9f60a424e606e7a930a) ，语法参考 ⌈ [sing-box 无头规则](https://sing-box.sagernet.org/zh/configuration/rule-set/headless-rule/) ⌋ 。


##

使用中有疑问可以通过 [Gmail](mailto:ffuiangg@gmail.com) 或 [Telegram](https://t.me/ffuqiangg) 联系我，发现代码有问题或者其它改进意见欢迎提交 PR / Issues 。
