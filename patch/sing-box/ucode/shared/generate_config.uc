#!/usr/bin/ucode

'use strict';

import { readfile, writefile } from 'fs';
import { cursor } from 'uci';

const uci = cursor();

uci.load('sing-box');
const conffile = uci.get('sing-box', 'main', 'conffile') || '/etc/sing-box/config.json',
      workdir = uci.get('sing-box', 'main', 'workdir') || '/etc/sing-box',
      remote = uci.get('sing-box', 'subscription', 'remote') || '1',
      level = uci.get('sing-box', 'log', 'level') || 'info',
      output = uci.get('sing-box', 'log', 'output') || '/var/log/sing-box.log',
      external_controller_port  = uci.get('sing-box', 'experimental', 'external_controller_port') || '9900',
      external_ui = uci.get('sing-box', 'experimental', 'external_ui') || 'ui',
      secret = uci.get('sing-box', 'experimental', 'secret') || 'ffuqiangg',
      ui_name = uci.get('sing-box', 'experimental', 'ui_name') || 'metacubexd',
      default_mode = uci.get('sing-box', 'experimental', 'default_mode') || 'rule',
      store_fakeip = uci.get('sing-box', 'experimental', 'store_fakeip') || '0',
      store_rdrc = uci.get('sing-box', 'experimental', 'store_rdrc') || '0',
      tproxy_port = uci.get('sing-box', 'inbounds', 'tproxy_port') || '10105',
      mixed_port = uci.get('sing-box', 'inbounds', 'mixed_port') || '2080',
      dns_port = uci.get('sing-box', 'inbounds', 'dns_port') || '2053',
      mixin = uci.get('sing-box', 'mix', 'mixin') || '0',
      mixfile = uci.get('sing-box', 'mix', 'mixfile') || '/etc/sing-box/mixin.json';

/* Config helper start */
let ui_url;
if (ui_name === 'metacubexd')
    ui_url = 'https://github.com/MetaCubeX/metacubexd/archive/refs/heads/gh-pages.zip';
else if (ui_name === 'zashboard')
    ui_url = 'https://github.com/Zephyruso/zashboard/archive/refs/heads/gh-pages.zip';
else if (ui_name === 'yacd')
    ui_url = 'https://github.com/MetaCubeX/Yacd-meta/archive/refs/heads/gh-pages.zip';

let profile_file;
if (remote === '0')
    profile_file = workdir + '/sing-box.json';
else if (remote >= '1')
    profile_file = workdir + '/subscription' + remote + '.json';

const route_rules_action = map(json(trim(readfile(profile_file))).route.rules, (v) => (v).action);

let outbounds_direct_tag, outbounds_block_tag;
for (let v in json(trim(readfile(profile_file))).outbounds) {
    if (v.type === 'direct')
        outbounds_direct_tag = v.tag;
}
for (let v in json(trim(readfile(profile_file))).outbounds) {
    if (v.type === 'block')
        outbounds_block_tag = v.tag;
}

let dns_block_tag;
for (let v in json(trim(readfile(profile_file))).dns.servers) {
    if (v.address === 'rcode://refused')
        dns_block_tag = v.tag;
}
/* Config helper end */

const config = {};

/* Log */
config.log = {
    disabled: false,
    level: level,
    output: output,
    timestamp: true
};

/* DNS */
config.dns = json(trim(readfile(profile_file))).dns;

if (!('hijack-dns' in route_rules_action)) {
    config.dns.servers = [];
    for (let v in json(trim(readfile(profile_file))).dns.servers) {
        if (v.tag !== dns_block_tag)
            push(config.dns.servers, v);
    }

    config.dns.rules = [];
    for (let v in json(trim(readfile(profile_file))).dns.rules) {
        if (v.server === dns_block_tag)
            push(config.dns.rules, json(replace(v, /"server": ".*"/, '\"action\": \"reject\"')));
        else
            push(config.dns.rules, v);
    }
}

/* Experimental */
config.experimental = {
    clash_api: {
        external_controller: '0.0.0.0:' + external_controller_port,
        external_ui: external_ui,
        secret: secret,
        external_ui_download_url: 'https://gh-proxy.com/' + ui_url,
        external_ui_download_detour: outbounds_direct_tag,
        default_mode: default_mode
    },
    cache_file: {
        enabled: true,
    }
};

(store_fakeip === '1') ? config.experimental.cache_file.store_fakeip = true : null;
(store_rdrc === '1') ? config.experimental.cache_file.store_rdrc = true : null;

/* Inbounds */
config.inbounds = [
    {
        type: 'tproxy',
        tag: 'tproxy-in',
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
    }
];

/* Outbounds */
config.outbounds = [];

for (let v in json(trim(readfile(profile_file))).outbounds) {
    if (!(v.type in ['dns', 'block']))
        push(config.outbounds, v);
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
        if (!(v.action in ['sniff', 'hijack-dns', 'reslove']))
            push(config.route.rules, v);
    }
} else {
    for (let v in json(trim(readfile(profile_file))).route.rules) {
        if (v.protocol !== 'dns') {
            if (v.outbound === outbounds_block_tag)
                push(config.route.rules, json(replace(v, /"outbound": ".*"/, '\"action\": \"reject\"')));
            else
                push(config.route.rules, v);
        }
    }
}

/* Mixin */
if (mixin === '1' && readfile(mixfile)) {
    for (let v in keys(json(trim(readfile(mixfile)))))
        config[v] = json(trim(readfile(mixfile)))[v];
}

/* Writefile */
writefile(conffile, sprintf('%.2J\n', (config)));
