## sing-box OpenWrt 安装与配置指南

本方案采用 `redirect(TCP)` + `tproxy(UDP)` 代理模式，兼容 **fw3** 与 **fw4**。支持订阅自动更新、节点过滤/分组、分流规则自定义、配置多个订阅自动合并。

> [!IMPORTANT]
> 仅支持 **IPv4**，不支持 IPv6。本项目不含订阅转换功能，如需转换请参考 [sing-box-subscribe 文档](subscribe.md) 。

📑 ⌈ [更新日志](changlog.md) ⌋


### 🚀 一键安装

```bash
sh -c "$(curl -ksS https://fastly.jsdelivr.net/gh/ffuqiangg/build_openwrt@main/patch/sing-box/install.sh)"
```

> [!WARNING]
> 1. 需固件支持 `ucode` `ucode-mod-uci` `ucode-mod-fs` `ucode-mod-digest` 。
> 2. 升级安装时如提示创建了备份文件 `/etc/config/sing-box.bak` ，说明配置文件格式发生变化须重新填写。
> 3. 安装 `zoneinfo-asia` (重启系统生效) 可解决日志时间戳错误，本仓库最新固件已默认编译。


### 🛠️ 服务管理

你可以通过命令行或系统启动项页面进行操作

启用 sing-box 服务
```shell
/etc/init.d/sing-box enable
```
使用以下命令立即启动 sing-box
```shell
/etc/init.d/sing-box start
```
使用以下命令使 sing-box 重新启动
```shell
/etc/init.d/sing-box restart
```
使用以下命令停止运行 sing-box
```shell
/etc/init.d/sing-box stop
```
禁用 sing-box 服务
```shell
/etc/init.d/sing-box disable
```

##

### 💡 快速上手 (最小配置)

1. **方案 A : 使用订阅链接**
- 修改 `main` 部分 : `option enabled '1'`
- 修改 `profile` 部分 : `list conf '订阅地址'`

2. **方案 B : 使用本地文件**
- 将配置文件上传至 `/etc/sing-box/profiles/` 目录
- 修改 `main` 部分 : `option enabled '1'`
- 修改 `profile` 部分 : `list conf 'file:文件名'`

##

### ⚙️ 核心配置详解

所有配置均通过修改 `/etc/config/sing-box` 实现

1. **基础设置 (main)**

```
config sing-box 'main'
	option enabled '0'                                   # 总开关，0/1
	option workdir '/etc/sing-box'                       # 运行目录 ( 此项不要修改 )
	option fuck_quic '1'                                 # 屏蔽 QUIC ，0/1
	option common_ports '0'                              # 仅代理常用端口，0/1
	option pass_cn_ip '0'                                # 跳过中国大陆 IP ，0/1
```
- `enabled` : 核心总开关。设为 1 服务脚本才能运行
- `common_ports` : 仅代理常用端口，可避免 P2P 下载流量进入 sing-box 核心
- `pass_cn_ip` : 中国大陆 IP 链接不进入 sing-box 核心

2. **配置管理 (profile)**

```
config sing-box 'profile'
	list prefix '[provider1] '                           # 前缀 1 ，用于多个配置时区分节点
	list conf ''                                         # 配置信息 1 ，支持订阅和本地配置文件
	list prefix '[provider2] '                           # 前缀 2 ，用于多个配置时区分节点
	list conf ''                                         # 配置信息 2 ，支持订阅和本地配置文件
	option restart_cron '0 5 * * *'                      # 定时重启 cron，留空禁用
```
- `prefix` : 节点名称前缀，与 `conf` 一一对应，仅配置多个 `conf` 时生效
- `conf` : 填入订阅地址或 `file:文件名` （本地文件），本地文件目录 `/etc/sing-box/profiles` 。更多配置可按格式自行添加
- `restart_cron` : 启用可实现定时更新订阅并重启服务
- 配置多个 `conf` 自动合并。合并功能依赖高级设置，此时高级设置自动生效不受 `advanced -> enabled` 影响

3. **进阶设置 (basic)**

```
config sing-box 'basic'
	option log_level 'warn'                              # 日志等级
	option log_file '/var/log/sing-box.log'              # 日志文件路径，留空则日志输出到 Web 面板
	option external_controller_port '9900'               # 后台页面端口
	option secret 'ffuqiangg'                            # 后台页面登陆密钥
	option ui_name 'zashboard'                           # Web 面板，可选值 metacubexd / zashboard / yacd
	option store_rdrc '1'                                # 缓存 rdrc ，0/1
	option tproxy_port '10105'                           # tproxy(UDP) 监听端口
	option mixed_port '2881'                             # mixed 代理端口
	option dns_port '2053'                               # DNS 入站端口 (direct)
	option redirect_port '2331'                          # redirect(TCP) 监听端口
```
- `mixed_port` : 提供 HTTP/SOCKS 混合代理
- 默认 Web 面板登录地址为 `http://路由器IP:9900/ui` (密码：ffuqiangg)
- 这部分配置的详细说明可以查看 ⌈ [sing-box 官方文档](https://sing-box.sagernet.org/zh/configuration/) ⌋ 的对应条目
- 如需修改端口配置要注意端口冲突，避免使用已占用的端口
- 更新或替换面板方法：删除 `/etc/sing-box/run/ui` 目录，然后重启 sing-box 服务

4. **高级设置 (advanced)**

```
config sing-box 'advanced'
	option enabled '1'                                   # 覆写，0/1
	option main_dns_type 'https'                         # 国外 DNS 类型
	option main_dns_server 'dns.google'                  # 国外 DNS 服务地址
	option china_dns_type 'h3'                           # 国内 DNS 类型
	option china_dns_server '223.5.5.5'                  # 国内 DNS 服务地址
	option ad_ruleset ''                                 # 去广告规则，留空禁用
	option nodes_filter ''                               # 排除节点关键字，留空禁用 (英文逗号分割)
	option area ''                                       # 地区分组，留空禁用 (英文逗号分割)
	option bypass ''                                     # 分流规则，留空禁用 (英文逗号分割)
```
- `enabled` : 禁用时所有高级设置均不生效，除了 `进阶设置` 涉及的部分外不会对配置文件做其它修改。配置有多个 `profile -> conf` 时高级设置默认开启不受此选项影响
- `ad_ruleset` : 去广告规则集下载地址，要求 srs 格式且地址可直连
- `bypass` : 注意前后顺序避免规则失效
- `area` 及 `bypass` 的数据基于 `/etc/sing-box/resources/stream.json` 文件，可按格式自行修改

5. **私货**

- 自用功能，运行结果不符合预期概不负责
- `advanced -> enabled` 开启或配置有多个 `profile -> conf` 时生效。用于自定义域名分流和强制域名直连 / 代理
- 在 `/etc/sing-box/resources` 目录新建 custom.json 文件。其 `top` 对象键为出站分组 / 节点 (如果分组不存在则自动创建)，值为一组无头规则。示例文件 [custom.json](https://gist.github.com/ffuqiangg/00a6acb48a1fb9f60a424e606e7a930a) ，语法参考 ⌈ [sing-box 无头规则](https://sing-box.sagernet.org/zh/configuration/rule-set/headless-rule/) ⌋


##

使用中有疑问可以通过 [Gmail](mailto:ffuiangg@gmail.com) 或 [Telegram](https://t.me/ffuqiangg) 联系我，发现代码有问题或者其它改进意见欢迎提交 PR / Issues 。
