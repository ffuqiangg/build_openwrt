## STREAM 分流文档

1. **节点区域分组**
```json
  "area_group": {
    "香港": {
      "type": "urltest",
      "filter": "🇭🇰|HK|hk|香港|HongKong"
    },
    "台湾": {
      "type": "urltest",
      "filter": "🇹🇼|TW|tw|台湾|Taiwan"
    },
    "日本": {
      "type": "urltest",
      "filter": "🇯🇵|JP|jp|日本|Japan"
    },
    "韩国": {
      "type": "urltest",
      "filter": "🇰🇷|KR|kr|韩国|Korea"
    },
    "新加坡": {
      "type": "urltest",
      "filter": "🇸🇬|SG|sg|新加坡|Singapore"
    },
    "美国": {
      "type": "urltest",
      "filter": "🇺🇸|US|us|美国|United States"
    },
    "德国": {
      "type": "urltest",
      "filter": "🇩🇪|DE|de|德国|Germany"
    }
  }
```
- `type` 分组类型，urltest 自动测速，selector 手动选择。
- `filter` 过滤节点使用的关键字，多个关键字用 `|` 分割。节点名称包含多个关键字中的任意一个，该节点即归入该分组。
- 默认分组无需删除，不包含节点的地区会自动跳过。例如：没有台湾节会自动忽略不生成台湾分组，更多地区分组可以按需要自行添加。

2. **路由分流**
```json
  "proxy_group": {
    "Google": {
      "geoip-google": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geoip/google.srs",
      "geosite-google": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geosite/google.srs"
    },
    "Github": {
      "geosite-github": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geosite/github.srs"
    },
    "Telegram": {
      "geoip-telegram": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geoip/telegram.srs",
      "geosite-telegram": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geosite/telegram.srs"
    },
    "OpenAI": {
      "geosite-openai": "https://testingcf.jsdelivr.net/gh/Toperlock/sing-box-geosite@main/rule/OpenAI.srs"
    },
    "DMM": {
      "geosite-dmm": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geosite/dmm.srs"
    },
    "HBO": {
      "geosite-hbo": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geosite/hbo.srs"
    },
    "NETFLIX": {
      "geoip-netflix": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geoip/netflix.srs",
      "geosite-netflix": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geosite/netflix.srs"
    },
    "Spotify": {
      "geosite-spotify": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geosite/spotify.srs"
    }
  }
```
- `Google` `Github` `Telegram` `OpenAI` `DMM` `HBO` `NETFLIX` `Spotify` 为分流名称，同时也作为面板中的分组名称。其下是该分流使用的规则集。
- 更多分流规则可按格式自行添加，要求使用 srs 格式且地址可直连。规则集地址对应的 key 为该规则集名称，自行设置不重复就行。
- `geosit-cn`，`geoip-cn`，`geosit-noncn` 规则集脚本已默认包含不用添加。

##

有疑问可以通过 [Gmail](mailto:ffuiangg@gmail.com) 或 [Telegram](https://t.me/ffuqiangg) 联系我。  