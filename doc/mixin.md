## MIXIN 文档

1. **去广告**
```json
  "fuck_ads": {
    "enabled": false,
    "rule_set": {
      "adguard-dns-filter": "https://testingcf.jsdelivr.net/gh/ffuqiangg/sing-box-adsruleset@main/rule/adguard-dns-filter.srs"
    }
  }
```
- `enabled` 功能开关，可选值：true 开启去广告，false 不使用去广告。
- `rule_set` 去广告使用的规则集，`adguard-dns-filter` 为规则集名称，后面的值是规则集下载地址。
- 如果要修改或增加新的规则集，取名时注意规则集名称不能重复，规则集下载地址必须是可以直连的地址。
- 默认规则集由 [AdGuard-DNS-filter](https://adguardteam.github.io/AdGuardSDNSFilter/Filters/filter.txt) 规则转换而来。

2. **DNS**
```json
  "dns": {
    "mode": "normal",
    "main_dns": "https://dns.cloudflare.com/dns-query",
    "china_dns": "h3://223.5.5.5/dns-query"
  }
```
- `mode` DNS 处理模式，可选值：normal，fakeip。
- `normal` 模式流程：命中规则集 `geosite-cn` 使用 `china_dns` > 同时命中规则集 `geosite-noncn`(取反) 和 `geoip-cn` 使用 `china_dns` > 其余使用 `main_dns` 。
- `fakeip` 模式流程：命中规则集 `geosite-cn` 使用 `china_dns` > A 类查询进入 fakeip 进程 > 其余使用 `main_dns` 。
- `mian_dns` 为全球 DNS，`china_dns` 为国内 DNS ，国内 DNS 必须使用 ip 形式的地址。

3. **区域节点分组**
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
- 默认分组无需删除，不包含节点的地区会自动跳过。例如：没有台湾节会自动忽略不生成台湾分组。
- 所有地区分组都会包含在路由分流规则使用的分组中，需要其它地区分组按格式添加即可。

4. **路由分流**
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
    "NETFLIX": {
      "geoip-netflix": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geoip/netflix.srs",
      "geosite-netflix": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geosite/netflix.srs"
    },
    "Spotify": {
      "geosite-spotify": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geosite/spotify.srs"
    }
  }
```
- `Google` `Github` `Telegram` `NETFLIX` `Spotify` 为路由分流规则名称，同时也作为面板中的分组名称。其下是该分流使用的规则集。
- 需要更多分流规则可以自行添加，规则集格式及要求与 DNS 使用的规则集相同。

##

有疑问可以通过 [Gmail](mailto:ffuiangg@gmail.com) 或 [Telegram](https://t.me/ffuqiangg) 联系我。  