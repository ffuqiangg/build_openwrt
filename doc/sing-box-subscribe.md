## sing-box-subscribe

如果使用的机场没有提供 sing-box 订阅，那么只能使用一些转换服务来将机场提供的订阅转换为 sing-box 格式。目前使用较为广泛的有 sing-box-subscribe 和 sub-store 两个项目。本文主要介绍 sing-box-subscribe 转换订阅的使用方法。

### 大陆白名单

如果只是想要大陆白名单规则和基础的订阅转换，可以直接使用下面的命令创建容器。再使用链接 `http://宿主机IP:5050/config/订阅链接` 作为 sing-box 订阅地址。

docker-compose
```docker-compse
services:
  subscribe:
    container_name: subscribe
    image: ffuqiangg/sing-box-subscribe
    network_mode: bridge
    ports:
      - 5050:5000
    restart: always
```
docker run
```docker
docker run -d \
  --name subscribe \
  -p 5050:5000 \
  -- restart always \
  ffuqiangg/sing-box-subscribe
```

### 自定义分流

1. **容器的创建使用**

自定义分流需要自己写模板文件放到 docker 宿主机中，然后用下面的命令创建容器。使用链接 `http://宿主机IP:5050/config/订阅链接` 作为 sing-box 订阅地址。

docker-compose
```docker-compse
services:
  subscribe:
    container_name: subscribe
    image: ffuqiangg/sing-box-subscribe
    network_mode: bridge
    volumes:
      - 模板文件目录:/sing-box-subscribe/config_template
    ports:
      - 5050:5000
    restart: always
```
docker run
```docker
docker run -d \
  --name subscribe \
  -v 模板文件目录:/sing-box-subscribe/config_template \
  -p 5050:5000 \
  -- restart always \
  ffuqiangg/sing-box-subscribe
```

2. **模板文件写法**

自定义分流的写法可以参考我自用的一个模板 [enhanced.json](https://github.com/ffuqiangg/sing-box-subscribe/blob/main/config_template/enhanced.json) ，sing-box-subscribe 模板文件中除了 outbounds 部分外都是标准的 sing-box 配置文件写法。以 Telegram 分流为例，一个完整的分流应该包含以下部分：

```json
{
  ...
  "outbounds": {
    ...
    {
      "tag":"Telegram",
      "type":"selector",  // selector 表示该分组中的 节点/分组 为手动选择
      "outbounds":[
        "节点选择",  // 节点选择，自动选择 两个分组一般作为总分组放到 outbounds 最前面。写法参考 enhanced.json
        "自动选择",
        "日本节点",  // 自定义分组，需要在 outbounds 中创建，写法在后面。
        "德国节点",
        "美国节点",
        "其它节点"
      ]
    },
    ...
    {
      "tag":"日本节点",
      "type":"urltest",  // urltest 表示该分组中的 节点/分组 自动选择延迟最低 
      "outbounds":[
        "{all}"  // {all} 指代所有的节点，有 filter 即使用其定义的方式过滤节点
      ],
      "filter":[
        {"action":"include","keywords":["JP"]}  // include 表示保留名称包含 keywords 关键字的节点，多个关键字可以用 | 分割
      ],
      "url": "http://www.apple.com/library/test/success.html",  // 用于测速的链接
      "interval": "10m",  // 测速间隔时间
      "tolerance": 50  // 测速容差，单位 ms
    },
    ...
    {
      "tag":"其它节点",
      "type":"urltest",
      "outbounds":[
        "{all}"
      ],
      "filter":[
        {"action":"exclude","keywords":["JP|DE|US"]}  // exclude 表示排除名称包含 keywords 关键字的节点，多个关键字可以用 | 分割
      ],
      "url": "http://www.apple.com/library/test/success.html",
      "interval": "10m",
      "tolerance": 50
    },
    {  // 用于直连的出站，一般放到所有分组的后面
      "type": "direct",
      "tag": "direct"
    }
  },
  "route": {
    ...
    "rules": [
      ...
      {
        "rule_set": ["geoip-telegram", "geosite-telegram"],  // 规则集
        "outbound": "Telegram"  // 符合规则集条件时使用的出站标签
      },
      ...
    ],
    "rule_set": [  // 这部分声明整个配置文件中用到的 rule_set 来源
      ...
      {
        "tag": "geoip-telegram",
        "type": "remote",
        "format": "binary",
        "url": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geoip/telegram.srs",
        "download_detour": "direct"  // 用于下载规则集的出站标签，推荐为 url 添加代理后使用直连出站
      },
      {
        "tag": "geosite-telegram",
        "type": "remote",
        "format": "binary",
        "url": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geosite/telegram.srs",
        "download_detour": "direct"
      },
      ...
    ]
  }
}
```

##

有疑问可以通过 [Gmail](mailto:ffuiangg@gmail.com) 或 [Telegram](https://t.me/ffuqiangg) 联系我。  