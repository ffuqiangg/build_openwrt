## sing-box 安装使用文档

重新写了一个 sing-box 服务。使用 tproxy 代理，fw3、fw4 都可以使用，支持自动下载订阅，自动重启更新订阅，修复了老方法 docker bridge 网络的联网问题，一些配置参数可自定义，也支持使用 json 模板文件自动修改配置文件，仅支持 ipv4，不支持 ipv6 。

本项目不具备订阅转换功能，如果机场没有提供 sing-box 订阅可以使用转换服务。仓库的另一篇 [文档](sing-box-subscribe.md) 中有使用 sing-box-subscribe 配合本项目使用的一些简单介绍。

**更新记录**  
`2025.02.06` 更新支持多订阅，并新增跳过中国大陆 IP 和仅代理常用端口功能。  
`2025.02.09` 修复了一些错误。另外：现在的版本仅支持 sing-box 1.10.x 版本，后续会支持 1.11.x 版本。  
`2025.02.10` 修复 fw3 上仅代理常用端口错误。  
`2025.02.14` 优化代码，新增新的本地文件运行方式和缓存 fakeip 开关。  
`2025.02.14-A` 更新至 sing-box 1.11.x 版本，不再支持 sing-box 1.10.x ，可以通过 `PassWall -> 组件更新` 页面查看和更新 sing-box 版本。使用中有任何问题可到仓库提 Issues 。  
`2025.02.22` 修复多网口设备获取子网地址错误及其它一些小错误，新增 mixed 代理端口设置。  
`2025.02.24` 新增 Web 面板选择，可选 MetaCubeXD，Zashboard，YACD 。  
`2025.04.01` 使用脚本语言 ucode 重构了大部分代码，不再依赖 jq ，但需要固件具备 ucode 支持。更新调整常用端口具体配置，修复仅代理常用端口时 mixed 代理失效的问题，取消本地 -1 运行方式，新增屏蔽 quic 开关、缓存 rdrc 开关，优化了防火墙规则，使用独立 DNS 入站端口避免 sing-box 核心不能正确劫持 DNS 请求。jq 版本仍可正常安装使用，且同步本次更新，但后续不再维护。  
`2025.04.04` 修复某些特定情况下无法正常下载 rule_set 规则集导致服务启动失败，自动为规则集 url 为 github.com 和 githubusercontent.com 的地址添加 github 代理并使用直连下载。  
`2025.04.08` 优化 DNS 转发，`网络 -> DHCP/DNS -> DNS 重定向` 选项开启时使用 DNSMASQ 转发 DNS ，未开启或没有此项则使用防火墙转发 DNS 。

### 安装命令

ucode 版本安装命令（推荐使用）
```bash
sh -c "$(curl -ksS https://testingcf.jsdelivr.net/gh/ffuqiangg/build_openwrt@main/patch/sing-box/ucode/install.sh)"
```
jq 版本安装命令（停止维护）
```bash
sh -c "$(curl -ksS https://testingcf.jsdelivr.net/gh/ffuqiangg/build_openwrt@main/patch/sing-box/jq/install.sh)"
```

- 注意本命令安装时会清空 /etc/sing-box 目录并初始化 /etc/config/sing-box 文件，如有需要请提前备份数据。
- 本仓库 2024.12.29 固件除 ImmortalWrt-18.06 不含 sing-box 核心之外都可使用 ucode 版本，iStoreOS 需要手动安装依赖项 ucode , ucode-mod-uci , ucode-mod-fs 。
- 日志文件时间戳如果出现时区错误，可通过安装 zoneinfo-asia (重启系统生效) 解决。

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
	option enabled '0'           # 总开关，设为 1 服务才能运行
	option conffile '/etc/sing-box/config.json'
	option workdir '/etc/sing-box'
```
- conffile 为配置文件路径、workdir 为服务运行目录，不要修改否则运行会出错。

2. **代理相关** `2025.04.01 更新增加屏蔽 quic 功能`
```config
config sing-box 'proxy'
	option common_ports '0'            # 仅代理常用端口，0 否，1 是
	option pass_cn_ip '0'              # 跳过中国大陆 IP，0 否，1 是
	option fuck_quic '0'               # 屏蔽 quic，0 否，1 是
```
- 使用 p2p 下载可开启仅代理常用端口，避免 p2p 流量进入 sing-box 核心。

3. **配置文件和订阅相关** `2025.04.01 更新取消本地 -1 运行方式`
```config
config sing-box 'subscription'
	option remote '1'                  # 使用订阅还是本地配置，0 本地配置文件，1 订阅1，2 订阅2 ...
	list url ''                        # 订阅链接 1
	list url ''                        # 订阅链接 2
	option auto_restart '1'            # 定时重启，0 关闭，1 开启
	option restart_cron '0 5 * * *'    # 定时重启 cron，默认为每天早上 5 点
```
- 本地配置文件保存到 /etc/sing-box 目录命名为 sing-box.json 。
- 使用订阅时服务启动会自动下载所有订阅，所以定时重启也能起到更新订阅的作用。
- 如果有更多订阅，配置中新建更多 `list url` 项目即可。

4. **网关相关配置** `2025,04.01 更新增加缓存 rdrc 开关、dns_port 入站端口设置`
```config
config sing-box 'log'
	option level 'warn'                     # 日志等级
	option output '/var/log/sing-box.log'   # 日志文件路径

config sing-box 'experimental'
	option external_controller_port '9900'  # 后台页面端口
	option external_ui 'ui'                 # 面板文件目录
	option secret 'ffuqiangg'               # 后台页面登陆密钥
	option ui_name 'metacubexd'             # Web 面板，可选值 metacubexd / zashboard / yacd
	option default_mode 'rule'              # clash 默认模式
	option store_fakeip '0'                 # 缓存 fakeip，0 禁用，1 启用
	option store_rdrc '0'                   # 缓存 rdrc，0 禁用，1 启用

config sing-box 'inbounds'
	option tproxy_port '10105'              # tproxy 监听端口
	option mixed_port '2080'                # mixed 代理端口
	option dns_port '2053'                  # DNS 入站端口 (direct)
```
- 按照默认设置面板登录地址为 `设备IP:9900/ui`，密钥 `ffuqiangg` 。
- 服务会按照本部分设置对配置文件做必要调整[^1]。
- 这部分配置的详细说明可以查看 sing-box [官方配置文档](https://sing-box.sagernet.org/zh/configuration/) 的对应条目。
- 如需修改端口选项要注意端口冲突，避免使用已占用的端口。
- mixed 代理提供 socks4, socks4a, socks5 和 http 代理服务（注意 mixed 仅代理 tcp 流量）。
- 更新或替换面板方法：删除 `/etc/sing-box/ui` 目录，然后重启 sing-box 服务。

[^1]: 服务会调整的部分包含完整的 `.log` `.experimental` 和 `.inbounds` ，以及 `.route.rules` 中与 inbounds 和 dns 相关的部分。

5. **模板**
```config
config sing-box 'mix'
	option mixin '0'                            # 模板功能，0 不启用，1 启用
	option mixfile '/etc/sing-box/mixin.json'   # 模板文件路径
```
- 模板功能通常配合订阅使用，用以对 dns route 等进行自定义。本地配置文件完全没必要使用这个功能直接修改配置文件就好。
- 模板功能会依照模板文件完整替换配置文件 `top-level` 的 objects 。且对配置文件的修改拥有最高权限，会覆盖服务脚本对配置文件的必要调整，一定要谨慎使用。
- 调整节点分组等涉及 `outbounds` 的部分，使用订阅转换服务会更加灵活。

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