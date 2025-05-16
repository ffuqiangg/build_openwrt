#!/usr/bin/ucode

'use strict';

import { readfile, writefile } from 'fs';
import { cursor } from 'uci';

/* UCI config start */
const uci = cursor();

uci.load('sing-box');
const conffile = uci.get('sing-box', 'main', 'conffile') || '/etc/sing-box/config.json',
      workdir = uci.get('sing-box', 'main', 'workdir') || '/etc/sing-box',
      remote = uci.get('sing-box', 'subscription', 'remote') || '1',
      level = uci.get('sing-box', 'log', 'level') || 'warn',
      log_file = uci.get('sing-box', 'log', 'log_file') || '0',
      output = uci.get('sing-box', 'log', 'output') || '/var/log/sing-box.log',
      external_controller_port  = uci.get('sing-box', 'experimental', 'external_controller_port') || '9900',
      external_ui = uci.get('sing-box', 'experimental', 'external_ui') || 'ui',
      secret = uci.get('sing-box', 'experimental', 'secret') || 'ffuqiangg',
      ui_name = uci.get('sing-box', 'experimental', 'ui_name') || 'metacubexd',
      default_mode = uci.get('sing-box', 'experimental', 'default_mode') || 'rule',
      store_rdrc = uci.get('sing-box', 'experimental', 'store_rdrc') || '0',
      tproxy_port = uci.get('sing-box', 'inbounds', 'tproxy_port') || '10105',
      mixed_port = uci.get('sing-box', 'inbounds', 'mixed_port') || '2881',
      dns_port = uci.get('sing-box', 'inbounds', 'dns_port') || '2053',
      redirect_port = uci.get('sing-box', 'inbounds', 'redirect_port') || '2331',
      mixin = uci.get('sing-box', 'mix', 'mixin') || '0';

const mixfile = trim(readfile(workdir + '/resources/mixin.json'));

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

const route_rules_action = map(json(jsonfile).route.rules, (v) => (v).action);

let outbounds_direct_tag, outbounds_block_tag, outbounds_dns_tag;
for (let v in json(jsonfile).outbounds) {
    if (v.type === 'direct')
        outbounds_direct_tag = v.tag;
    else if (v.type === 'block')
        outbounds_block_tag = v.tag;
    else if (v.type === 'dns')
        outbounds_dns_tag = v.tag;
}
/* UCI config end */

/* Config helper start */
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
/* Config helper end */

const config = {};

/* Log */
config.log = {
    disabled: false,
    level: level,
    output: (log_file === '1') ? output : null,
    timestamp: true
};

/* DNS */
if (mixin === '1') {
    config.dns = {
        servers: [
            {
                tag: 'main-dns',
                address: json(mixfile).dns.main_dns,
                address_resolver: 'china-dns'
            },
            {
                tag: 'china-dns',
                address: json(mixfile).dns.china_dns,
                detour: '直连'
            }
        ],
        rules: [
            {
                outbound: 'any',
                server: 'china-dns'
            },
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
            }
        ]
    };

    if (json(mixfile).fuck_ads.enabled === true)
        push (config.dns.rules, {
            rule_set: keys(json(mixfile).fuck_ads.rule_set),
            action: 'reject'
        });

    push(config.dns.rules, {
        rule_set: 'geosite-cn',
        server: 'china-dns'
    });

    if (json(mixfile).dns.mode === 'fakeip') {
        if (length(json(mixfile).dns.main_dns2) > 0)
            push (config.dns.servers, {
                tag: 'main-dns2',
                address: json(mixfile).dns.main_dns2,
                address_resolver: 'china-dns'
            });

        if (length(json(mixfile).dns.china_dns2) > 0)
            push (config.dns.servers, {
                tag: 'chian-dns2',
                address: json(mixfile).dns.china_dns2,
                detour: '直连'
            });

        push (config.dns.servers, {
            address: 'fakeip',
            tag: 'fakeip'
        });

        push (config.dns.rules, {
            query_type: 'A',
            server: 'fakeip'
        });

        config.dns.fakeip = {
            enabled: true,
            inet4_range: '198.18.0.0/15'
        };
        config.dns.independent_cache = true;
    }

    if (json(mixfile).dns.mode === 'enhanced') {
        push(config.dns.rules, {
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
        });
    }

    config.dns.strategy = 'ipv4_only';
    config.dns.final = 'main-dns';
} else {
    config.dns = json(jsonfile).dns;
}

/* Experimental */
config.experimental = {
    clash_api: {
        external_controller: '0.0.0.0:' + external_controller_port,
        external_ui: external_ui,
        secret: secret,
        external_ui_download_url: 'https://gh-proxy.com/' + ltrim(ui_url, 'https://'),
        external_ui_download_detour: (mixin === '1') ? '直连' : outbounds_direct_tag,
        default_mode: default_mode
    },
    cache_file: {
        enabled: true,
        store_fakeip: (exists(config.dns, 'fakeip')) ? config.dns.fakeip.enabled : null,
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
if (mixin === '1') {
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

    /* nodes help */
    let nodes_list = [];
    for (let v in json(jsonfile).outbounds) {
        if (!(v.type in ['direct', 'dns', 'block', 'selector', 'urltest']))
            push(nodes_list, v.tag);
    }

    let nodes_area = [];
    for (let v in keys(json(mixfile).area_group)) {
        map(nodes_list, (x) => {
            for (let k in split(json(mixfile)['area_group'][v]['filter'], '|')) {
                if (index(x, k) > -1)
                    push(nodes_area, v);
            }
        });
    }
    nodes_area = uniq(nodes_area);

    /* main-group */
    push(config.outbounds[0].outbounds, '自动选择');
    for (let v in nodes_area)
        push(config.outbounds[0].outbounds, v);
    push(config.outbounds[0].outbounds, '直连');
    for (let v in nodes_list) {
        push(config.outbounds[0].outbounds, v);
        push(config.outbounds[1].outbounds, v);
    }

    /* proxy-group */
    let proxy_group_out = [];
    push(proxy_group_out, '节点选择');
    for (let k in nodes_area)
        push(proxy_group_out, k);
    push(proxy_group_out, '直连');
    for (let k in nodes_list)
        push(proxy_group_out, k);

    for (let v in keys(json(mixfile).proxy_group)) {
        push(config.outbounds, {
            tag: v,
            type: 'selector',
            outbounds: proxy_group_out
        });
    }

    /* area-group */
    for (let v in nodes_area) {
        push(config.outbounds, {
            tag: v,
            type: json(mixfile)['area_group'][v]['type'],
            outbounds: nodesFilter(json(mixfile)['area_group'][v]['filter'], nodes_list)
        });
    }

    /* direct */
    push(config.outbounds, {
        tag: '直连',
        type: 'direct'
    });

    /* nodes */
    for (let v in json(jsonfile).outbounds) {
        if (!(v.type in ['direct', 'dns', 'block', 'selector', 'urltest']))
            push(config.outbounds, v);
    }
} else {
    config.outbounds = [];

    for (let v in json(jsonfile).outbounds) {
        if (!(v.type in ['dns', 'block']))
            push(config.outbounds, v);
    }
}

for (let i = 0; i < length(config.outbounds); i++) {
    if (!(config.outbounds[i].type in ['selector', 'urltest', 'block']))
        config.outbounds[i].routing_mark = '101';
}

/* Route */
if (mixin === '1') {
    config.route = {
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

    /* fuck_ads */
    if (json(mixfile).fuck_ads.enabled === true) {
        push(config.route.rules, {
            rule_set: keys(json(mixfile).fuck_ads.rule_set),
            action: 'reject'
        });

        for (let k in keys(json(mixfile).fuck_ads.rule_set)) {
            push(config.route.rule_set, {
                tag: k,
                type: 'remote',
                format: 'binary',
                url: json(mixfile)['fuck_ads']['rule_set'][k],
                download_detour: '直连'
            });
        }
    }

    /* proxy-group route */
    for (let k in keys(json(mixfile).proxy_group)) {
        push(config.route.rules, {
            rule_set: keys(json(mixfile)['proxy_group'][k]),
            outbound: k
        });

        for (let v in keys(json(mixfile)['proxy_group'][k])) {
            push(config.route.rule_set, {
                tag: v,
                type: 'remote',
                format: 'binary',
                url: json(mixfile)['proxy_group'][k][v],
                download_detour: '直连'
            });
        }
    }

    push(config.route.rules, {
        rule_set: [
            'geosite-cn',
            'geoip-cn'
        ],
        outbound: '直连'
    });

    /* route rule_set */
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

    if (json(mixfile).dns.mode === 'enhanced')
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

    if ('hijack-dns' in route_rules_action) {
        for (let v in json(jsonfile).route.rules) {
            if (!(v.action in ['sniff', 'hijack-dns']))
                push(config.route.rules, v);
        }
    } else {
        for (let v in json(jsonfile).route.rules) {
            if (v.outbound !== outbounds_dns_tag) {
                if (v.outbound === outbounds_block_tag)
                    push(config.route.rules, json(replace(v, /"outbound": ".*"/, '\"action\": \"reject\"')));
                else
                    push(config.route.rules, v);
            }
        }
    }

    config.route.rule_set = [];

    for (let k in json(jsonfile).route.rule_set) {
        if (k.download_detour !== outbounds_direct_tag && match(k.url, /[(github\.com)(githubusercontent\.com)]/)) {
            push(config.route.rule_set, {
                type: k.type,
                tag: k.tag,
                format: k.format,
                url: 'https://gh-proxy.com/' + ltrim(k.url, 'https://'),
                download_detour: outbounds_direct_tag,
                update_interval: k.update_interval ? k.update_interval : null
            });
        } else {
            push(config.route.rule_set, k);
        }
    }
}

/* Writefile */
writefile(conffile, sprintf('%.2J\n', removeBlankAttrs(config)));
