## sing-box 安装使用文档

重新写了一个 sing-box 服务。使用 tproxy 代理，fw3、fw4 都可以使用，支持自动下载订阅，自动重启更新订阅，修复了老方法 docker 桥接容器不能联网的问题，一些配置参数可自定义，也支持使用 json 模板文件自动修改配置文件。

### 安装命令

```bash
sh -c "$(curl -ksS https://gh-proxy.com/raw.githubusercontent.com/ffuqiangg/build_openwrt/main/patch/sing-box/install.sh)"
```

- 注意本命令安装时会清空 /etc/sing-box 目录，有需要的请提前备份文件。
- 本仓库除 ImmortalWrt-18.06 之外的固件都能直接安装使用。如果使用的其它固件需要安装有 sing-box 和 jq 。
- 如果在非本仓库固件中使用，注意本项目只支持 sing-box 1.10.x，且仅在 N1 硬件上测试过。其它硬件是否可用未知。

### 使用基础

- `/etc/init.d/sing-box enable` 启用服务 = 开机自启
- `/etc/init.d/sing-box disable` 禁用服务 = 关闭开机自启
- `/etc/init.d/sing-box start` 启动服务
- `/etc/init.d/sing-box stop` 停止服务
- `/etc/init.d/sing-box restart` 重启服务

以上命令分别对应 `启动项` 页面 `sing-box` 一行的 `已禁用`，`已启用`，`启动`，`停止`，`重启` 按钮。

### 配置服务

所有的配置选项都通过修改 /etc/config/sing-box 文件实现，下面分几个部分说明其各个项目的作用。

1. **基本设置**
```config
config sing-box 'main'
	option enabled '0'    # 总开关，设为 1 服务才能运行
	option conffile '/etc/sing-box/config.json'
	option workdir '/etc/sing-box'
```
- conffile 为配置文件路径、workdir 为服务运行目录，一般情况不建议修改。

2. **配置文件和订阅相关**
```config
config sing-box 'subscription'
	option remote '1'                  # 控制使用订阅还是本地配置文件，1 使用订阅，改为 0 使用本地配置文件
	option url ''                      # 订阅链接
	option auto_restart '1'            # 是否开启定义重启，由于启动时会自动更新订阅也作为自动更新用
	option restart_cron '0 5 * * *'    # 自动重启 cron，默认为每天早上 5 点
```
- 如果使用本地配置文件保存到 /etc/sing-box 目录命名为 sing-box.json 。
- url 为空时即使 remote 设置为 1，也会使用本地配置文件启动，如果本地配置文件也不存在自动停止运行。

3. **基本配置参数**
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
- 修改端口项目时注意端口冲突，避免使用已被其它插件占用的端口。

4. **模板**
```config
config sing-box 'mix'
	option mixin '0'  # 是否开启模板功能
	option mixfile '/etc/sing-box/mixin.json'   # 模板文件路径
```
- 这个功能通常配合订阅使用，用以对 DNS route 等进行自定义。本地配置文件完全没必要使用这个功能直接修改原文件就好。
- 服务默认只修改必要的部分以满足作为代理网关使用的需求，需要更多自定义就可以使用这个功能。范本 [mixin.json](https://gist.github.com/ffuqiangg/d9bfcb1b37e58e6450711cd8060b57c8)，更多请参考[官方配置文档](https://sing-box.sagernet.org/zh/configuration/)。

### 简单配置

后台地址： IP:9900/ui | 密钥： ffuqiangg

1. **使用订阅**
```config
config sing-box 'main'
	option enabled '1'

config sing-box 'subscription'
	option url '订阅地址'
```

2. **使用本地配置文件**  
将配置文件放到 /etc/sing-box 目录命令为 sing-box.json
```config
config sing-box 'main'
	option enabled '1'
```
