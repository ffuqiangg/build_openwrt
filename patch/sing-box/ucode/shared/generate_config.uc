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
      mixin = uci.get('sing-box', 'mix', 'mixin') || '0',
      mixfile = uci.get('sing-box', 'mix', 'mixfile') || '/etc/sing-box/mixin.json';

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

const route_rules_action = map(json(trim(readfile(profile_file))).route.rules, (v) => (v).action);

let outbounds_direct_tag, outbounds_block_tag, outbounds_dns_tag;
for (let v in json(trim(readfile(profile_file))).outbounds) {
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
config.dns = json(trim(readfile(profile_file))).dns;

/* Experimental */
config.experimental = {
    clash_api: {
        external_controller: '0.0.0.0:' + external_controller_port,
        external_ui: external_ui,
        secret: secret,
        external_ui_download_url: 'https://gh-proxy.com/' + ltrim(ui_url, 'https://'),
        external_ui_download_detour: outbounds_direct_tag,
        default_mode: default_mode
    },
    cache_file: {
        enabled: true,
        store_rdrc: (store_rdrc === '1') || null
    }
};

if (exists(config.dns, 'fakeip')) {
    config.experimental.cache_file.store_fakeip = config.dns.fakeip.enabled;
}

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
config.outbounds = [];

for (let v in json(trim(readfile(profile_file))).outbounds) {
    if (!(v.type in ['dns', 'block']))
        push(config.outbounds, v);
}

for (let i = 0; i < length(config.outbounds); i++) {
    if (!(config.outbounds[i].type in ['selector', 'urltest']))
        config.outbounds[i].routing_mark = '101';
}

/* Route */
config.route = json(trim(readfile(profile_file))).route;

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
    for (let v in json(trim(readfile(profile_file))).route.rules) {
        if (!(v.action in ['sniff', 'hijack-dns']))
            push(config.route.rules, v);
    }
} else {
    for (let v in json(trim(readfile(profile_file))).route.rules) {
        if (v.outbound !== outbounds_dns_tag) {
            if (v.outbound === outbounds_block_tag)
                push(config.route.rules, json(replace(v, /"outbound": ".*"/, '\"action\": \"reject\"')));
            else
                push(config.route.rules, v);
        }
    }
}

config.route.rule_set = [];

for (let k in json(trim(readfile(profile_file))).route.rule_set) {
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

/* Mixin */
if (mixin === '1' && readfile(mixfile)) {
    for (let v in keys(json(trim(readfile(mixfile)))))
        config[v] = json(trim(readfile(mixfile)))[v];
}

/* Writefile */
writefile(conffile, sprintf('%.2J\n', removeBlankAttrs(config)));
