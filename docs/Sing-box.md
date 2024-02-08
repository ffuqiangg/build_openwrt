## OpenWrt 23.05 固件 sing-box 使用文档

如果你的机场提供了 sing-box 订阅链接直接将配置文件下载到 /etc/sing-box 目录。如果机场没有提供 sing-box 订阅 google 搜索 sing-box 订阅转换服务。

```bash
cd /etc/sing-box
wget -U "sing-box" "订阅地址" -O xxx.json
```

> [!TIP]
> 可以保存多个订阅的配置文件，注意从文件名进行区分。

然后需要视情况对配置文件进行一些修改。

```json
"clash_api":{ 
    "external_controller": "0.0.0.0:9900",
    "external_ui": "ui",
    "secret": "ffuqiangg",
    "external_ui_download_url": "https://mirror.ghproxy.com/https://github.com/MetaCubeX/Yacd-meta/archive/gh-pages.  zip"
}
```

上面的代码对比你配置文件中的 clash_api 部分。 
- **external_controller** 影响 clash 面板的访问地址，大部分机场提供的配置该值为 "127.0.0.1:9090"。`:` 前的地址必须修改为 `0.0.0.0`，后面的端口可随意设置只要不与系统本身及其它插件冲突即可。
- **external_ui** 影响 clash 面板源码保存的目录，可随意设置，多个配置文件中使用了不同的面板须设置不同的值。( 如果目录已存在会直接使用目录下源码作为面板 )
- **secret** 为 clash 面板的登录密码随意设置。
- **external_ui_download_url** 为 clash 面板静态网页资源的 ZIP 下载地址，当 external_ui 设置的目录不存在时才会生效。实例为 yacd 面板设置，要使用 metacubexd 面板修改为 "https://github.com/MetaCubeX/metacubexd/archive/gh-pages.zip"

按照上面的说明修改好配置文件后复制配置文件为 config.json 就完成了配置文件的准备工作。执行下面的命令即可启动 sing-box。

```bash
/etc/init.d/sing-box start
```

如果你都按照上面示例的代码修改的配置文件那么面板访问地址就是 `http://设备IP:9900/ui`

### 更新订阅

更新订阅需要前往 OpenWrt 的 `计划任务` 页面或者编辑 `/etc/crontabs/root` 文件手动添加计划任务，如果配置文件需要修改可用 sed 命令实现。可以趁此机会学习一点 linux 知识也是不错的。

```bash
# 这每天 6:00 下载配置文件修改地址，替换 config.json 文件并重新读取 config.json
0 6 * * * wget -O /etc/sing-box/test.json -U "sing-box" "订阅地址" && sed -i 's/127.0.0.1:9090/0.0.0.0:9900/' /etc/sing-box/test.json && cp -f /etc/sing-box/test.json /etc/sing-box/config.json && /etc/init.d/sing-box reload
```

> [!TIP]
> config.json 如有变动须执行 /etc/init.d/sing-box reload 重新读取配置文件方可生效。
