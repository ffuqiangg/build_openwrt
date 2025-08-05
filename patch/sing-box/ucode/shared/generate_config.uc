#!/usr/bin/ucode

'use strict';

import { readfile, writefile, basename, access } from 'fs';
import { cursor } from 'uci';

function removeBlankAttrs(res) {
    let content;

    if (type(res) === 'object') {
        content = {};
        map(keys(res), (k) => {
            if (type(res[k]) in ['array', 'object'])
                content[k] = removeBlankAttrs(res[k]);
            else if (res[k] !== null && res[k] !== '')
                content[k] = res[k];
        });
    } else if (type(res) === 'array') {
        content = [];
        map(res, (k, i) => {
            if (type(k) in ['array', 'object'])
                push(content, removeBlankAttrs(k));
            else if (k !== null && k !== '')
                push(content, k);
        });
    } else {
        return res;
    }

    return content;
};

function nodesFilter(key, list) {
    let content = [];

    map(list, (x) => {
        for (let k in split(key, '|')) {
            if (index(x, k) > -1)
                push(content, x);
        }
    });

    return uniq(content);
};

/* UCI config start */
const uci = cursor();

uci.load('sing-box');
const conffile = uci.get('sing-box', 'main', 'conffile') || '/etc/sing-box/config.json',
      workdir = uci.get('sing-box', 'main', 'workdir') || '/etc/sing-box',
      remote = uci.get('sing-box', 'subscription', 'remote') || '1',
      level = uci.get('sing-box', 'basic', 'level') || 'warn',
      log_file = uci.get('sing-box', 'basic', 'log_file') || '0',
      output = uci.get('sing-box', 'basic', 'output') || '/var/log/sing-box.log',
      external_controller_port  = uci.get('sing-box', 'basic', 'external_controller_port') || '9900',
      external_ui = uci.get('sing-box', 'basic', 'external_ui') || 'ui',
      secret = uci.get('sing-box', 'basic', 'secret') || 'ffuqiangg',
      ui_name = uci.get('sing-box', 'basic', 'ui_name') || 'metacubexd',
      default_mode = uci.get('sing-box', 'basic', 'default_mode') || 'rule',
      store_rdrc = uci.get('sing-box', 'basic', 'store_rdrc') || '0',
      tproxy_port = uci.get('sing-box', 'basic', 'tproxy_port') || '10105',
      mixed_port = uci.get('sing-box', 'basic', 'mixed_port') || '2881',
      dns_port = uci.get('sing-box', 'basic', 'dns_port') || '2053',
      redirect_port = uci.get('sing-box', 'basic', 'redirect_port') || '2331',
      override = uci.get('sing-box', 'advanced', 'override') || '1',
      main_dns_type = uci.get('sing-box', 'advanced', 'main_dns_type') || 'https',
      main_dns_server = uci.get('sing-box', 'advanced', 'main_dns_server') || 'dns.google',
      china_dns_type = uci.get('sing-box', 'advanced', 'china_dns_type') || 'h3',
      china_dns_server = uci.get('sing-box', 'advanced', 'china_dns_server') || '223.5.5.5',
      filter_nodes = uci.get('sing-box', 'advanced', 'filter_nodes') || '0',
      filter_keywords = uci.get('sing-box', 'advanced', 'filter_keywords') || '流量,套餐,重置,官網,官网,群组',
      adblock = uci.get('sing-box', 'advanced', 'adblock') || '0',
      ad_ruleset = uci.get('sing-box', 'advanced', 'ad_ruleset') || '',
      group_nodes = uci.get('sing-box', 'advanced', 'group_nodes') || '0',
      stream = uci.get('sing-box', 'advanced', 'stream') || '0',
      stream_list = uci.get('sing-box', 'advanced', 'stream_list') || 'Google,Github,Telegram,OpenAI,Spotify';

const streamfile = trim(readfile(workdir + '/resources/stream.json'));

let ui_url;
if (ui_name === 'metacubexd')
    ui_url = 'https://github.com/MetaCubeX/metacubexd/archive/refs/heads/gh-pages.zip';
else if (ui_name === 'zashboard')
    ui_url = 'https://github.com/Zephyruso/zashboard/releases/latest/download/dist.zip';
else if (ui_name === 'yacd')
    ui_url = 'https://github.com/MetaCubeX/Yacd-meta/archive/refs/heads/gh-pages.zip';

let profile_file;
if (remote === '0')
    profile_file = workdir + '/sing-box.json';
else if (remote >= '1')
    profile_file = workdir + '/subscription' + remote + '.json';
const jsonfile = trim(readfile(profile_file));

let outbounds_direct_tag;
for (let v in json(jsonfile).outbounds)
    if (v.type === 'direct')
        outbounds_direct_tag = v.tag;

let nodes_list = [];
for (let v in json(jsonfile).outbounds)
    if (!(v.type in ['direct', 'dns', 'block', 'selector', 'urltest']))
        push(nodes_list, v.tag);
if (filter_nodes === '1')
    for (let v in split(filter_keywords, ','))
        nodes_list = filter(nodes_list, x => index(x, v) == -1);

let nodes_area = [];
for (let v in keys(json(streamfile).area_group))
    map(nodes_list, (x) => {
        for (let k in split(json(streamfile)['area_group'][v]['filter'], '|'))
            if (index(x, k) > -1)
                push(nodes_area, v);
    });
nodes_area = uniq(nodes_area);

let area_nodes = [];
for (let v in nodes_area)
    for (let k in nodesFilter(json(streamfile)['area_group'][v]['filter'], nodes_list))
        push(area_nodes, k);

let proxy_group_out = [];
push(proxy_group_out, '节点选择');
if (group_nodes === '1') {
    for (let k in nodes_area)
        push(proxy_group_out, k);
    if (length(nodes_list) > length(area_nodes))
        push(proxy_group_out, '其他');
}
push(proxy_group_out, '直连');
for (let k in nodes_list)
    push(proxy_group_out, k);

let ad_rulelist = [];
for (let i = 0; i < length(ad_ruleset); i++)
    push(ad_rulelist, rtrim(basename(ltrim(ad_ruleset[i], 'https:/')), '.srs'));
ad_rulelist = filter(ad_rulelist, length);

let custom_file;
if (access(workdir + '/resources/custom.json'))
    custom_file = trim(readfile(workdir + '/resources/custom.json'));
const outbounds_list = split(join(',', nodes_list) + ',' + join(',', nodes_area) + ',' + stream_list + ',节点选择,自动选择,直连', ',');
/* UCI config end */

const config = {};

/* Log */
config.log = {
    disabled: false,
    level: level,
    output: (log_file === '1') ? output : null,
    timestamp: true
};

/* DNS */
if (override === '1') {
    config.dns = {
        servers: [
            {
                tag: 'main-dns',
                type: main_dns_type,
                server: main_dns_server,
                domain_resolver: 'china-dns',
                detour: '节点选择'
            },
            {
                tag: 'china-dns',
                type: china_dns_type,
                server: china_dns_server
            }
        ],
        rules: [
            {
                clash_mode: 'global',
                server: 'main-dns'
            },
            {
                clash_mode: 'direct',
                server: 'china-dns'
            },
            {
                domain_suffix: [
                    'services.googleapis.cn',
                    'xn--ngstr-lra8j.com'
                ],
                server: 'main-dns'
            },
            {
                rule_set: 'geosite-cn',
                server: 'china-dns'
            },
            {
                type: 'logical',
                mode: 'and',
                rules: [
                    {
                        rule_set: 'geosite-noncn',
                        invert: true
                    },
                    {
                        rule_set: 'geoip-cn'
                    }
                ],
                server: 'china-dns'
            }
        ],
        final: 'main-dns',
        strategy: 'ipv4_only',
        disable_cache: false,
        disable_expire: false
    };
} else {
    config.dns = json(jsonfile).dns;
}

/* Experimental */
let dns_types = [];
for (let i = 0; i < length(config.dns.servers); i++)
    push(dns_types, config.dns.servers[i],type);
dns_types = uniq(dns_types);

config.experimental = {
    clash_api: {
        external_controller: '0.0.0.0:' + external_controller_port,
        external_ui: external_ui,
        secret: secret,
        external_ui_download_url: 'https://gh-proxy.com/' + ltrim(ui_url, 'https://'),
        external_ui_download_detour: (override === '1') ? '直连' : outbounds_direct_tag,
        default_mode: default_mode
    },
    cache_file: {
        enabled: true,
        store_fakeip: ('fakeip' in dns_types) || null,
        store_rdrc: (store_rdrc === '1') || null
    }
};

/* Inbounds */
config.inbounds = [
    {
        type: 'tproxy',
        tag: 'tproxy-in',
        network: 'udp',
        listen: '::',
        listen_port: int(tproxy_port)
    },
    {
        type: 'mixed',
        tag: 'mixed-in',
        listen: '::',
        listen_port: int(mixed_port)
    },
    {
        type: 'direct',
        tag: 'dns-in',
        listen: '::',
        listen_port: int(dns_port)
    },
    {
        type: 'redirect',
        tag: 'redirect-in',
        listen: '::',
        listen_port: int(redirect_port)
    }
];

/* Outbounds */
if (override === '1') {
    config.outbounds = [
        {
            tag: '节点选择',
            type: 'selector',
            outbounds: []
        },
        {
            tag: '自动选择',
            type: 'urltest',
            outbounds: []
        }
    ];

    /* main-group */
    push(config.outbounds[0].outbounds, '自动选择');
    if (group_nodes === '1') {
        for (let v in nodes_area)
            push(config.outbounds[0].outbounds, v);
        if (length(nodes_list) > length(area_nodes))
            push(config.outbounds[0].outbounds, '其他');
    }
    push(config.outbounds[0].outbounds, '直连');
    for (let v in nodes_list) {
        push(config.outbounds[0].outbounds, v);
        push(config.outbounds[1].outbounds, v);
    }

    /* for myself */
    if (custom_file)
        for (let v in filter(keys(json(custom_file)), x => (!(x in outbounds_list))))
            push(config.outbounds, {
                tag: v,
                type: 'selector',
                outbounds: proxy_group_out
            });

    /* proxy-group */
    if (stream === '1')
        for (let v in split(stream_list, ','))
            push(config.outbounds, {
                tag: v,
                type: 'selector',
                outbounds: proxy_group_out
            });

    /* area-group */
    if (group_nodes === '1') {
        for (let v in nodes_area) {
            push(config.outbounds, {
                tag: v,
                type: json(streamfile)['area_group'][v]['type'],
                outbounds: nodesFilter(json(streamfile)['area_group'][v]['filter'], nodes_list)
            });
        }

        if (length(nodes_list) > length(area_nodes))
            push(config.outbounds, {
                tag: '其他',
                type: 'urltest',
                outbounds: filter(nodes_list, x => (!(x in area_nodes)))
            });
    }

    /* direct */
    push(config.outbounds, {
        tag: '直连',
        type: 'direct'
    });

    /* nodes */
    for (let v in json(jsonfile).outbounds)
        if (v.tag in nodes_list)
            push(config.outbounds, v);

} else {
    config.outbounds = json(jsonfile).outbounds;
}

for (let i = 0; i < length(config.outbounds); i++)
    if (!(config.outbounds[i].type in ['selector', 'urltest', 'block', 'dns']))
        config.outbounds[i].routing_mark = '101';

/* Route */
if (override === '1') {
    config.route = {
        default_domain_resolver: {
            server: 'china-dns'
        },
        final: '节点选择',
        auto_detect_interface: true,
        rules: [
            {
                action: 'sniff'
            },
            {
                inbound: 'dns-in',
                action: 'hijack-dns'
            },
            {
                clash_mode: 'direct',
                outbound: '直连'
            },
            {
                clash_mode: 'global',
                outbound: '节点选择'
            },
            {
                domain_suffix: [
                    'services.googleapis.cn',
                    'xn--ngstr-lra8j.com'
                ],
                outbound: '节点选择'
            },
            {
                ip_is_private: true,
                outbound: '直连'
            }
        ],
        rule_set: []
    };

    /* adblock */
    if (adblock === '1') {
        push(config.route.rules, {
            rule_set: ad_rulelist,
            action: 'reject'
        });

        for (let i = 0; i < length(ad_rulelist); i++)
            push(config.route.rule_set, {
                tag: ad_rulelist[i],
                type: 'remote',
                format: 'binary',
                url: ad_ruleset[i],
                download_detour: '直连'
            });
    }

    /* for myself */
    if (custom_file) {
        for (let k in keys(json(custom_file))) {
            push(config.route.rules, {
                rule_set: k + '-ruleset',
                outbound: k
            });
            push(config.route.rule_set, {
                tag: k + '-ruleset',
                type: 'inline',
                rules: json(custom_file)[k]
            });
        }
    }

    /* proxy-group route */
    if (stream === '1') {
        for (let k in split(stream_list, ',')) {
            push(config.route.rules, {
                rule_set: keys(json(streamfile)['proxy_group'][k]),
                outbound: k
            });

            for (let v in keys(json(streamfile)['proxy_group'][k]))
                push(config.route.rule_set, {
                    tag: v,
                    type: 'remote',
                    format: 'binary',
                    url: json(streamfile)['proxy_group'][k][v],
                    download_detour: '直连'
                });
        }
    }

    /* cn-direct */
    push(config.route.rules, {
        rule_set: [
            'geosite-cn',
            'geoip-cn'
        ],
        outbound: '直连'
    });

    /* main rule_set */
    push(config.route.rule_set, {
        tag: 'geosite-cn',
        type: 'remote',
        format: 'binary',
        url: 'https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geosite/geolocation-cn.srs',
        download_detour: '直连'
    });
    push(config.route.rule_set, {
        tag: 'geoip-cn',
        type: 'remote',
        format: 'binary',
        url: 'https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geoip/cn.srs',
        download_detour: '直连'
    });
    push(config.route.rule_set, {
        tag: 'geosite-noncn',
        type: 'remote',
        format: 'binary',
        url: 'https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geosite/geolocation-!cn.srs',
        download_detour: '直连'
    });
} else {
    config.route = json(jsonfile).route;

    config.route.rules = [
        {
            action: 'sniff'
        },
        {
            inbound: 'dns-in',
            action: 'hijack-dns'
        }
    ];

    for (let v in json(jsonfile).route.rules)
        if (!(v.action in ['sniff', 'hijack-dns']))
            push(config.route.rules, v);
}

/* Writefile */
writefile(conffile, sprintf('%.2J\n', removeBlankAttrs(config)));
