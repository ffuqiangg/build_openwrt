## sing-box 安装使用文档

重新写了一个 sing-box 服务。使用 tproxy 代理，fw3、fw4 都可以使用，支持自动下载订阅，自动重启更新订阅，修复了老方法 docker bridge 网络的联网问题，一些配置参数可自定义，也支持使用 json 模板文件自动修改配置文件，仅支持 ipv4，不支持 ipv6 。

**更新记录**  
`2025.02.06` 更新支持多订阅，并新增跳过中国大陆 IP 和仅代理常用端口功能。  
`2035.02.09` 修复了一些错误。另外：现在的版本仅支持 sing-box 1.10.x 版本，后续会支持 1.11.x 版本。  
`2035.02.10` 修复 fw3 上仅代理常用端口错误。

### 安装命令

```bash
sh -c "$(curl -ksS https://gh-proxy.com/raw.githubusercontent.com/ffuqiangg/build_openwrt/main/patch/sing-box/install.sh)"
```

- 注意本命令安装时会清空 /etc/sing-box 目录，如有需要请提前备份数据。
- 本仓库固件除 ImmortalWrt-18.06 之外都能直接安装使用。如果使用的其它固件则需要安装有 sing-box 和 jq 。

### 使用基础

- `/etc/init.d/sing-box enable` 启用服务 = 开机自启
- `/etc/init.d/sing-box disable` 禁用服务 = 关闭开机自启
- `/etc/init.d/sing-box start` 启动服务
- `/etc/init.d/sing-box stop` 停止服务
- `/etc/init.d/sing-box restart` 重启服务

以上命令分别对应 `启动项` 页面 `sing-box` 一行的 `已禁用`，`已启用`，`启动`，`停止`，`重启` 按钮。

### 配置服务

所有的配置选项都通过修改 /etc/config/sing-box 文件实现，下面分几个部分说明其各个选项的作用。文末有分别使用订阅链接和本地配置文件的[极简配置](#极简配置)实例。  

1. **基本设置**
```config
config sing-box 'main'
	option enabled '0'           # 总开关，设为 1 服务才能运行
	option conffile '/etc/sing-box/config.json'
	option workdir '/etc/sing-box'
```
- conffile 为配置文件路径、workdir 为服务运行目录，一般情况不建议修改。

2. **代理相关** `2025.02.06 新增功能`
```config
config sing-box 'proxy'
	option common_ports '0'      # 仅代理常用端口，0 否，1 是
	option pass_cn_ip '0'        # 跳过中国大陆 IP，0 否，1 是
```
- 使用 p2p 下载可开启仅代理常用端口，避免 p2p 流量经过节点。

3. **配置文件和订阅相关** `2025.02.06 更新支持多订阅`
```config
config sing-box 'subscription'
	option remote '1'                  # 使用订阅还是本地配置，0 本地配置，1 订阅1，2 订阅2 ...
	list url ''                        # 订阅链接 1
	list url ''                        # 订阅链接 2
	option auto_restart '1'            # 定时重启，0 关闭，1 开启
	option restart_cron '0 5 * * *'    # 自动重启 cron，默认为每天早上 5 点
```
- 本地配置文件保存到 /etc/sing-box 目录命名为 sing-box.json 。
- 服务启动时会自动下载所有订阅，所以定时重启也能起到更新订阅的作用。
- 如果有更多订阅，配置中新建更多 list url 选项即可。

4. **网关相关配置**
```config
config sing-box 'log'
	option level 'warn'                     # 日志等级
	option output '/var/log/sing-box.log'   # 日志文件路径

config sing-box 'experimental'
	option external_controller_port '9900'  # 后台页面端口
	option external_ui 'ui'                 # 后台页面后缀目录
	option secret 'ffuqiangg'               # 后台页面登陆密钥
	option default_mode 'rule'              # clash 默认模式

config sing-box 'inbounds'
	option tproxy_port '10105'              # tproxy 监听端口
```
- 这部分配置的详细说明可以查看 sing-box [官方配置文档](https://sing-box.sagernet.org/zh/configuration/)的对应项目。
- 本部分配置并不建议修改，如需修改端口选项要注意端口冲突，避免使用已被其它插件占用的端口。

5. **模板**
```config
config sing-box 'mix'
	option mixin '0'                            # 模板功能，0 不启用，1 启用
	option mixfile '/etc/sing-box/mixin.json'   # 模板文件路径
```
- 模板功能通常配合订阅使用，用以对 DNS route 等进行自定义。本地配置文件完全没必要使用这个功能直接修改原文件就好。
- 服务默认只修改必要的部分以满足作为代理网关使用的需求，需要更多自定义就可以使用这个功能。范本 [mixin.json](https://gist.github.com/ffuqiangg/d9bfcb1b37e58e6450711cd8060b57c8)，更多请参考[官方配置文档](https://sing-box.sagernet.org/zh/configuration/)。

### 极简配置

后台地址：IP:9900/ui | 密钥：ffuqiangg

1. **使用订阅** 修改如下选项
```config
config sing-box 'main'
	option enabled '1'

config sing-box 'subscription'
	option url '订阅地址'
```

2. **使用本地配置文件** 将配置文件放到 /etc/sing-box 目录命令为 sing-box.json，并修改如下选项
```config
config sing-box 'main'
	option enabled '1'

	config sing-box 'subscription'
	option remote '0'
```
