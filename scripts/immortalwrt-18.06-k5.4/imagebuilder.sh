#!/bin/bash

make_path="${PWD}"
openwrt_dir="imagebuilder"
imagebuilder_path="${make_path}/${openwrt_dir}"

error_msg() {
    echo -e "❌ ${1}"
    exit 1
}

download_imagebuilder() {
    cd "${make_path}"
    echo -e "🍺 Start downloading OpenWrt files..."

    # Downloading imagebuilder files
    curl -fsSOL 'https://downloads.immortalwrt.org/releases/18.06-k5.4-SNAPSHOT/targets/armvirt/64/immortalwrt-imagebuilder-18.06-k5.4-SNAPSHOT-armvirt-64.Linux-x86_64.tar.xz'
    [[ "${?}" -eq "0" ]] || error_msg "Download failed"
    echo -e "💬 The [ imagebuilder files ] is downloaded successfully."

    # Unzip and change the directory name
    tar -xJf ./*-imagebuilder-* && sync && rm -f ./*-imagebuilder-*.tar.xz
    mv -f ./*-imagebuilder-* ${openwrt_dir}

    sync && sleep 3
    echo -e "💬 [ ${make_path} ] directory status: $(ls . -l 2>/dev/null)"
}

adjust_settings() {
    cd "${imagebuilder_path}"
    echo -e "🍺 Start adjusting .config file settings..."

    if [[ -s ".config" ]]; then
        sed -i "s|CONFIG_TARGET_ROOTFS_CPIOGZ=.*|# CONFIG_TARGET_ROOTFS_CPIOGZ is not set|g" .config
        sed -i "s|CONFIG_TARGET_ROOTFS_EXT4FS=.*|# CONFIG_TARGET_ROOTFS_EXT4FS is not set|g" .config
        sed -i "s|CONFIG_TARGET_ROOTFS_SQUASHFS=.*|# CONFIG_TARGET_ROOTFS_SQUASHFS is not set|g" .config
        sed -i "s|CONFIG_TARGET_IMAGES_GZIP=.*|# CONFIG_TARGET_IMAGES_GZIP is not set|g" .config
        sed -i "s|CONFIG_TARGET_ROOTFS_PARTSIZE=.*|CONFIG_TARGET_ROOTFS_PARTSIZE=820|g" .config
    else
        echo -e "💬 [ ${imagebuilder_path} ] directory status: $(ls -al 2>/dev/null)"
        error_msg "There is no .config file"
    fi

    # For custom packages
    mkdir -p custom_packages && sed -i '/custom/a\src custom file:custom_packages' repositories.conf

    sync && sleep 3
    echo -e "💬 [ openwrt ] directory status: $(ls -al 2>/dev/null)"
}

custom_packages() {
    cd "${imagebuilder_path}"
    echo -e "🍺 Start adding custom packages..."
    custom_packages_list=""
    github_api="https://api.github.com/repos"
    packages_list=$(jq -c 'keys' "${packages_json_file}" | sed -e 's/\[//' -e 's/\]//' -e 's/,/ /g')

    [[ -d "packages" ]] || mkdir packages
    cd packages

    ### luci-app-amlogic
    amlogic_api="https://api.github.com/repos/ophub/luci-app-amlogic/releases"
    # luci
    amlogic_file="luci-app-amlogic"
    amlogic_file_down="$(curl -s ${amlogic_api} | grep "browser_download_url" | grep -oE "https.*${amlogic_file}.*.ipk" | head -n 1)"
    curl -fsSOJL ${amlogic_file_down}
    [[ "${?}" -eq "0" ]] || error_msg "[ ${amlogic_file} ] download failed!"
    echo -e "💬 The [ ${amlogic_file} ] is downloaded successfully."
    # i18n
    amlogic_i18n="luci-i18n-amlogic"
    amlogic_i18n_down="$(curl -s ${amlogic_api} | grep "browser_download_url" | grep -oE "https.*${amlogic_i18n}.*.ipk" | head -n 1)"
    curl -fsSOJL ${amlogic_i18n_down}
    [[ "${?}" -eq "0" ]] || error_msg "[ ${amlogic_i18n} ] download failed!"
    echo -e "💬 The [ ${amlogic_i18n} ] is downloaded successfully."

    ### Passwall
    passwall_api="https://api.github.com/repos/xiaorouji/openwrt-passwall/releases"
    # luci
    passwall_file="luci-app-passwall"
    passwall_file_down="$(curl -s ${passwall_api} | grep "browser_download_url" | grep -oE "https.*19.07_${passwall_file}.*.ipk" | head -n 1)"
    curl -fsSOJL ${passwall_file_down}
    [[ "${?}" -eq "0" ]] || error_msg "[ ${passwall_file} ] download failed!"
    echo -e "💬 The [ ${passwall_file} ] is downloaded successfully."
    # i18n
    passwall_i18n="luci-i18n-passwall"
    passwall_i18n_down="$(curl -s ${passwall_api} | grep "browser_download_url" | grep -oE "https.*19.07_${passwall_i18n}.*.ipk" | head -n 1)"
    curl -fsSOJL ${passwall_i18n_down}
    [[ "${?}" -eq "0" ]] || error_msg "[ ${passwall_i18n} ] download failed!"
    echo -e "💬 The [ ${passwall_i18n} ] is downloaded successfully."
    # packages
    passwall_packages_down="$(curl -s ${passwall_api} | grep "browser_download_url" | grep -oE "https.*passwall_packages.*cortex-a53.zip" | head -n 1)"
    curl -fsSOJL ${passwall_packages_down}
    [[ "${?}" -eq "0" ]] || error_msg "[ passwall_packages ] download failed!"
    unzip *.zip && rm *.zip v2ray-geo*.ipk
    echo -e "💬 The [ passwall_packages ] is downloaded successfully."

    ### MosDNS
    curl -fsSOJL 'https://github.com/sbwml/luci-app-mosdns/releases/download/v4.5.3/luci-app-mosdns_1.4.4_all.ipk'
    [[ "${?}" -eq "0" ]] || error_msg "[ luci-app-mosdns ] download failed!"
    echo -e "💬 The [ luci-app-mosdns ] is downloaded successfully."
    curl -fsSOJL 'https://github.com/sbwml/luci-app-mosdns/releases/download/v4.5.3/mosdns_4.5.3-1_aarch64_cortex-a53.ipk'
    [[ "${?}" -eq "0" ]] || error_msg "[ luci-i18n-mosdns ] download failed!"
    echo -e "💬 The [ luci-i18n-mosdns ] is downloaded successfully."
    # geodata
    geodata_api="https://api.github.com/repos/sbwml/luci-app-mosdns/releases"
    geoip_down="$(curl -s ${geodata_api} | grep "browser_download_url" | grep -oE "https.*v2ray-geoip.*.ipk" | head -n 1)"
    curl -fsSOJL ${geoip_down}
    [[ "${?}" -eq "0" ]] || error_msg "[ v2ray-geoip ] download failed!"
    echo -e "💬 The [ v2ray-geoip ] is downloaded successfully."
    geosite_down="$(curl -s ${geodata_api} | grep "browser_download_url" | grep -oE "https.*v2ray-geosite.*.ipk" | head -n 1)"
    curl -fsSOJL ${geosite_down}
    [[ "${?}" -eq "0" ]] || error_msg "[ v2ray-geosite ] download failed!"
    echo -e "💬 The [ v2ray-geosite ] is downloaded successfully."

    ### OpenClash
    openclash_api="https://api.github.com/repos/vernesong/OpenClash/releases"
    openclash_down="$(curl -s ${openclash_api} | grep "browser_download_url" | grep -oE "https.*openclash.*.ipk" | head -n 1)"
    curl -fsSOJL ${openclash_down}
    [[ "${?}" -eq "0" ]] || error_msg "[ openclash ] download failed!"
    mv *openclash*.ipk ${imagebuilder_path}/custom_packages/
    echo -e "💬 The [ openclash ] is downloaded successfully."

    ### V2rayA
    cp -rf ../../files/v2raya/* ./
    [[ "${?}" -eq "0" ]] || error_msg "[ v2raya ] download failed!"
    echo -e "💬 The [ v2raya ] is downloaded successfully."

    sync && sleep 3
    echo -e "💬 [ packages ] directory status: $(ls packages -l 2>/dev/null)"
}

custom_files() {
    cd "${imagebuilder_path}"
    echo -e "🍺 Start adding custom files..."

    # Copy custom files
    [[ -d "files" ]] || mkdir -p files/etc/uci-defaults
    cp -rf ../../files/init/* files/
    cp -f ../../patch/default-settings/immortalwrt-18.06/99-default-settings files/etc/uci-defaults/

    # banner
    echo "
[0;1;34;94mImmortalWrt-18.06-k5.4[0m $(date +%Y.%m.%d)
" > files/etc/banner

    # OpenClash core
    mkdir -p files/etc/openclash/core
    wget -qO- https://github.com/vernesong/OpenClash/raw/core/master/meta/clash-linux-arm64.tar.gz | tar xOvz > files/etc/openclash/core/clash_meta
    chmod +x files/etc/openclash/core/clash*

    sync && sleep 3
    echo -e "💬 [ files ] directory status: $(ls files -l 2>/dev/null)"
}

rebuild_firmware() {
    cd "${imagebuilder_path}"
    echo -e "🍺 Start building OpenWrt with Image Builder..."

    my_packages="\
        acpid attr base-files bash bc blkid block-mount blockd bsdtar \
        btrfs-progs busybox bzip2 cgi-io chattr comgt comgt-ncm containerd coremark \
        coreutils coreutils-base64 coreutils-nohup coreutils-truncate curl docker \
        docker-compose dockerd dosfstools dumpe2fs e2freefrag e2fsprogs exfat-mkfs \
        f2fs-tools f2fsck fdisk gawk getopt gzip hostapd-common iconv iw iwinfo jq jshn \
        kmod-brcmfmac kmod-brcmutil kmod-cfg80211 kmod-mac80211 libjson-script \
        liblucihttp liblucihttp-lua libnetwork losetup lsattr lsblk lscpu mkf2fs \
        mount-utils openssl-util parted perl-http-date perlbase-file perlbase-getopt \
        perlbase-time perlbase-unicode perlbase-utf8 pigz ppp ppp-mod-pppoe \
        proto-bonding pv rename resize2fs runc subversion-client subversion-libs tar \
        tini ttyd tune2fs uclient-fetch uhttpd uhttpd-mod-ubus unzip uqmi usb-modeswitch \
        uuidgen wget-ssl whereis which wpad-basic wwan xfs-fsck xfs-mkfs xz iperf3 \
        xz-utils ziptool zoneinfo-asia zoneinfo-core zstd vim-fuller htop iftop \
        \
        luci luci-base luci-compat luci-i18n-base-en luci-i18n-base-zh-cn luci-lib-base \
        luci-lib-docker luci-lib-ip luci-lib-ipkg luci-lib-jsonc luci-lib-nixio \
        luci-mod-admin-full luci-mod-network luci-mod-status luci-mod-system \
        luci-proto-3g luci-proto-bonding luci-proto-ipip luci-proto-ipv6 luci-proto-ncm \
        luci-proto-openconnect luci-proto-ppp luci-proto-qmi luci-proto-relay \
        \
        luci-i18n-diskman-zh-cn luci-i18n-hd-idle-zh-cn luci-i18n-nlbwmon-zh-cn luci-theme-bootstrap \
        luci-i18n-ddns-zh-cn luci-i18n-dockerman-zh-cn luci-i18n-firewall-zh-cn \
        luci-i18n-frpc-zh-cn luci-i18n-opkg-zh-cn luci-i18n-samba4-zh-cn luci-i18n-ttyd-zh-cn \
        luci-i18n-upnp-zh-cn luci-i18n-wol-zh-cn luci-i18n-turboacc-zh-cn kmod-tcp-bbr dnsforwarder dnsproxy \
        kmod-ipt-offload kmod-fast-classifier luci-i18n-arpbind-zh-cn luci-i18n-autoreboot-zh-cn -luci-app-cpufreq \
        -luci-i18n-cpufreq-zh-cn luci-i18n-cpulimit-zh-cn luci-i18n-filebrowser-zh-cn \
        \
        luci-i18n-amlogic-zh-cn luci-i18n-passwall-zh-cn  chinadns-ng -luci-app-openclash luci-app-openclash \
        naiveproxy shadowsocks-rust-sslocal shadowsocks-rust-ssserver simple-obfs-client xray-core \
        sing-box luci-i18n-mosdns-zh-cn mosdns v2ray-geoip v2ray-geosite luci-i18n-v2ray-zh-cn \
        "

    make image PROFILE="Default" PACKAGES="${my_packages}" FILES="files"

    sync && sleep 3
    echo -e "💬 [ imagebuilder/bin/targets/*/* ] directory status: $(ls bin/targets/*/* -l 2>/dev/null)"
    echo -e "💬 The rebuild is successful, the current path: [ ${PWD} ]"
}

echo -e "🍺 Welcome to Rebuild OpenWrt Using the Image Builder."
[[ -x "${0}" ]] || error_msg "Please give the script permission to run: [ chmod x ${0} ]"
echo -e "💬 Rebuild path: [ ${PWD} ]"
echo -e "💬 Server space usage before starting to compile: \n$(df -hT "${make_path}") \n"

download_imagebuilder
adjust_settings
custom_packages
custom_config
custom_files
rebuild_firmware

echo -e "Server space usage after compilation: \n$(df -hT "${make_path}") \n"

wait