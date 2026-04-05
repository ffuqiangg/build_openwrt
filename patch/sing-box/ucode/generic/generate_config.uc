#!/usr/bin/ucode

'use strict';

import { readfile, writefile, access } from 'fs';
import { cursor } from 'uci';

/* function start */
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

function isEmpty(res) {
    return !res || res === 'nil' || (type(res) in ['array', 'object'] && length(res) === 0);
};

function addPrefix(arr, prefix) {
    let content = arr;

    for (let i = 0; i < length(content); i++)
        content[i].tag = prefix + content[i].tag;

    return content;
}
/* function end */

/* UCI config start */
const uci = cursor();

uci.load('sing-box');
const workdir = uci.get('sing-box', 'main', 'workdir') || '/etc/sing-box',
      profile = uci.get('sing-box', 'profile', 'profile') || 'sub:1',
      prefix = uci.get('sing-box', 'profile', 'prefix') || '',
      url = uci.get('sing-box', 'profile', 'url') || '',
      log_level = uci.get('sing-box', 'basic', 'log_level') || 'warn',
      log_file = uci.get('sing-box', 'basic', 'log_file') || 'nil',
      external_controller_port  = uci.get('sing-box', 'basic', 'external_controller_port') || '9900',
      external_ui = uci.get('sing-box', 'basic', 'external_ui') || 'ui',
      secret = uci.get('sing-box', 'basic', 'secret') || '',
      ui_name = uci.get('sing-box', 'basic', 'ui_name') || 'zashboard',
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
      ad_ruleset = uci.get('sing-box', 'advanced', 'ad_ruleset') || 'nil',
      nodes_filter = uci.get('sing-box', 'advanced', 'nodes_filter') || 'nil',
      area = uci.get('sing-box', 'advanced', 'area') || 'nil',
      bypass = uci.get('sing-box', 'advanced', 'bypass') || 'nil';

const streamfile = trim(readfile(workdir + '/resources/stream.json'));

let ui_url;
if (ui_name === 'metacubexd')
    ui_url = 'https://github.com/MetaCubeX/metacubexd/archive/refs/heads/gh-pages.zip';
else if (ui_name === 'zashboard')
    ui_url = 'https://github.com/Zephyruso/zashboard/releases/latest/download/dist.zip';
else if (ui_name === 'yacd')
    ui_url = 'https://github.com/MetaCubeX/Yacd-meta/archive/refs/heads/gh-pages.zip';

let jsonfile;
if (index(profile, 'file:') == 0)
    jsonfile = trim(readfile(workdir + '/profiles/' + ltrim(profile, 'file:')));
else if (index(profile, 'sub:') == 0)
    jsonfile = trim(readfile(workdir + '/profiles/subscription' + ltrim(profile, 'sub:') + '.json'));

let direct_tag;
if (!(profile === 'all'))
    for (let v in json(jsonfile).outbounds)
        if (v.type === 'direct')
            direct_tag = v.tag;

let nodes_list_tag = [];
let outbounds_nodes_all = [];
if (profile === 'all') {
    for (let i = 0; i < length(url); i++)
        for (let v in addPrefix(json(trim(readfile(workdir + '/profiles/subscription' + (i + 1) + '.json'))).outbounds, prefix[i]))
            if (!(v.type in ['direct', 'dns', 'block', 'selector', 'urltest'])) {
                push(nodes_list_tag, v.tag);
                push(outbounds_nodes_all, v);
            }
} else {
    for (let v in json(jsonfile).outbounds)
        if (!(v.type in ['direct', 'dns', 'block', 'selector', 'urltest']))
            push(nodes_list_tag, v.tag);
}
if (!isEmpty(nodes_filter))
    for (let v in split(nodes_filter, ','))
        nodes_list_tag = filter(nodes_list_tag, x => index(x, v) == -1);

let nodes_area_tag = [];
if (!isEmpty(area))
    for (let v in split(area, ','))
        for (let k in nodesFilter(json(streamfile)['area_group'][v]['filter'], nodes_list_tag))
            push(nodes_area_tag, k);

let selector_group_outbounds = [];
push(selector_group_outbounds, '节点选择');
if (!isEmpty(area)) {
    for (let k in split(area, ','))
        push(selector_group_outbounds, k);
    if (length(nodes_list_tag) > length(nodes_area_tag))
        push(selector_group_outbounds, '其他');
}
push(selector_group_outbounds, '直连');
for (let k in nodes_list_tag)
    push(selector_group_outbounds, k);

let custom_file;
if (access(workdir + '/resources/custom.json'))
    custom_file = trim(readfile(workdir + '/resources/custom.json'));
/* UCI config end */

const config = {};

/* Log */
config.log = {
    disabled: false,
    level: log_level,
    output: !isEmpty(log_file) ? log_file : null,
    timestamp: true
};

/* DNS */
if (override === '1' || profile === 'all') {
    config.dns = {
        servers: [
            {
                tag: 'main-dns',
                type: main_dns_type,
                server: main_dns_server,
                domain_resolver: !(iptoarr(main_dns_server)) ? 'china-dns' : null,
                detour: '节点选择'
            },
            {
                tag: 'china-dns',
                type: china_dns_type,
                server: china_dns_server,
                domain_resolver: !(iptoarr(china_dns_server)) ? 'default-dns' : null,
                detour: '直连'
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

    if (!(iptoarr(china_dns_server)))
        push(config.dns.servers, {
            tag: 'default-dns',
            type: 'udp',
            server: '223.5.5.5',
            detour: '直连'
        });
} else {
    config.dns = json(jsonfile).dns;
}

/* Experimental */
let dns_types = [];
for (let i = 0; i < length(config.dns.servers); i++)
    push(dns_types, config.dns.servers[i].type);
dns_types = uniq(dns_types);

config.experimental = {
    clash_api: {
        external_controller: '0.0.0.0:' + external_controller_port,
        external_ui: external_ui,
        external_ui_download_url: 'https://gh-proxy.com/' + ltrim(ui_url, 'https://'),
        external_ui_download_detour: (override === '1' || profile === 'all') ? '直连' : direct_tag,
        secret: secret
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
if (override === '1' || profile === 'all') {
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
    for (let v in selector_group_outbounds)
        push(config.outbounds[0].outbounds, v);
    config.outbounds[0].outbounds[0] = '自动选择';
    for (let v in nodes_list_tag)
        push(config.outbounds[1].outbounds, v);

    /* for myself */
    if (custom_file)
        for (let v in filter(keys(json(custom_file)), x => (!(x in selector_group_outbounds))))
            push(config.outbounds, {
                tag: v,
                type: 'selector',
                outbounds: selector_group_outbounds
            });

    /* bypass-group */
    if (!isEmpty(bypass))
        for (let v in split(bypass, ','))
            push(config.outbounds, {
                tag: v,
                type: 'selector',
                outbounds: selector_group_outbounds
            });

    /* area-group */
    if (!isEmpty(area)) {
        for (let v in split(area, ',')) {
            push(config.outbounds, {
                tag: v,
                type: json(streamfile)['area_group'][v]['type'],
                outbounds: nodesFilter(json(streamfile)['area_group'][v]['filter'], nodes_list_tag)
            });
        }

        if (length(nodes_list_tag) > length(nodes_area_tag))
            push(config.outbounds, {
                tag: '其他',
                type: 'urltest',
                outbounds: filter(nodes_list_tag, x => (!(x in nodes_area_tag)))
            });
    }

    /* direct */
    push(config.outbounds, {
        tag: '直连',
        type: 'direct'
    });

    /* nodes */
    if (profile === 'all') {
        for (let v in outbounds_nodes_all)
            if (v.tag in nodes_list_tag)
                push(config.outbounds, v);
    } else {
        for (let v in json(jsonfile).outbounds)
            if (v.tag in nodes_list_tag)
                push(config.outbounds, v);
    }
} else {
    config.outbounds = json(jsonfile).outbounds;
}

for (let i = 0; i < length(config.outbounds); i++)
    if (!(config.outbounds[i].type in ['selector', 'urltest', 'block', 'dns']))
        config.outbounds[i].routing_mark = '101';

/* Route */
if (override === '1' || profile === 'all') {
    config.route = {
        final: '节点选择',
        auto_detect_interface: true,
        default_domain_resolver: 'china-dns',
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
    if (!isEmpty(ad_ruleset)) {
        push(config.route.rules, {
            rule_set: 'adblock',
            action: 'reject'
        });

        push(config.route.rule_set, {
            tag: 'adblock',
            type: 'remote',
            format: 'binary',
            url: ad_ruleset,
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
    if (!isEmpty(bypass)) {
        for (let k in split(bypass, ',')) {
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

    /* final */
    push(config.route.rules, {
        rule_set: [
            'geosite-cn',
            'geoip-cn'
        ],
        outbound: '直连'
    });
    push(config.route.rules, {
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
writefile(workdir + '/run/config.json', sprintf('%.2J\n', removeBlankAttrs(config)));
