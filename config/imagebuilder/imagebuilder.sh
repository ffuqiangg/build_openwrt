#!/bin/bash

# Set default parameters
make_path="${PWD}"
openwrt_dir="openwrt"
imagebuilder_path="${make_path}/${openwrt_dir}"
custom_files_path="${make_path}/files"
custom_config_file="${make_path}/config/imagebuilder/config"

# Set default parameters
STEPS="[\033[95m STEPS \033[0m]"
INFO="[\033[94m INFO \033[0m]"
SUCCESS="[\033[92m SUCCESS \033[0m]"
WARNING="[\033[93m WARNING \033[0m]"
ERROR="[\033[91m ERROR \033[0m]"
#
#================================================================================================

# Encountered a serious error, abort the script execution
error_msg() {
    echo -e "${ERROR} ${1}"
    exit 1
}

# Downloading OpenWrt ImageBuilder
download_imagebuilder() {
    cd ${make_path}
    echo -e "${STEPS} Start downloading OpenWrt files..."

    # Determine the target system (Imagebuilder files naming has changed since 23.05.0)
    if [[ "${op_branch:0:2}" -ge "23" && "${op_branch:3:2}" -ge "05" ]]; then
        target_system="armsr/armv8"
        target_name="armsr-armv8"
        target_profile=""
    else
        target_system="armvirt/64"
        target_name="armvirt-64"
        target_profile="Default"
    fi

    # Downloading imagebuilder files
    download_file="https://downloads.${op_sourse}.org/releases/${op_branch}/targets/${target_system}/${op_sourse}-imagebuilder-${op_branch}-${target_name}.Linux-x86_64.tar.xz"
    wget -q ${download_file}
    [[ "${?}" -eq "0" ]] || error_msg "Wget download failed: [ ${download_file} ]"

    # Unzip and change the directory name
    tar -xJf *-imagebuilder-* && sync && rm -f *-imagebuilder-*.tar.xz
    mv -f *-imagebuilder-* ${openwrt_dir}

    sync && sleep 3
    echo -e "${INFO} [ ${make_path} ] directory status: $(ls . -l 2>/dev/null)"
}

# Adjust related files in the ImageBuilder directory
adjust_settings() {
    cd ${imagebuilder_path}
    echo -e "${STEPS} Start adjusting .config file settings..."

    # For .config file
    if [[ -s ".config" ]]; then
        # Root filesystem archives
        sed -i "s|CONFIG_TARGET_ROOTFS_CPIOGZ=.*|# CONFIG_TARGET_ROOTFS_CPIOGZ is not set|g" .config
        # Root filesystem images
        sed -i "s|CONFIG_TARGET_ROOTFS_EXT4FS=.*|# CONFIG_TARGET_ROOTFS_EXT4FS is not set|g" .config
        sed -i "s|CONFIG_TARGET_ROOTFS_SQUASHFS=.*|# CONFIG_TARGET_ROOTFS_SQUASHFS is not set|g" .config
        sed -i "s|CONFIG_TARGET_IMAGES_GZIP=.*|# CONFIG_TARGET_IMAGES_GZIP is not set|g" .config
    else
        error_msg "There is no .config file in the [ ${download_file} ]"
    fi

    # For other files
    # ......

    sync && sleep 3
    echo -e "${INFO} [ openwrt ] directory status: $(ls -al 2>/dev/null)"
}

# Add custom packages
# If there is a custom package or ipk you would prefer to use create a [ packages ] directory,
# If one does not exist and place your custom ipk within this directory.
custom_packages() {
    cd ${imagebuilder_path}
    echo -e "${STEPS} Start adding custom packages..."

    # Create a [ packages ] directory
    [[ -d "packages" ]] || mkdir packages

    # Download luci-app-amlogic
    amlogic_api="https://api.github.com/repos/ophub/luci-app-amlogic/releases"
    amlogic_file="luci-app-amlogic"
    amlogic_file_down="$(curl -s ${amlogic_api} | grep "browser_download_url" | grep -oE "https.*${amlogic_file}.*.ipk" | head -n 1)"
    wget ${amlogic_file_down} -q -P packages
    [[ "${?}" -eq "0" ]] || error_msg "[ ${amlogic_file} ] download failed!"
    echo -e "${INFO} The [ ${amlogic_file} ] is downloaded successfully."
    amlogic_i18n="luci-i18n-amlogic"
    amlogic_i18n_down="$(curl -s ${amlogic_api} | grep "browser_download_url" | grep -oE "https.*${amlogic_i18n}.*.ipk" | head -n 1)"
    wget ${amlogic_i18n_down} -q -P packages
    [[ "${?}" -eq "0" ]] || error_msg "[ ${amlogic_i18n} ] download failed!"
    echo -e "${INFO} The [ ${amlogic_i18n} ] is downloaded successfully."

    # Download luci-app-mosdns
    # mosdns_api="https://api.github.com/repos/sbwml/luci-app-mosdns/releases"
    # mosdns_file_down="$(curl -s ${mosdns_api}/latest | grep "browser_download_url" | grep -e "https.*all.ipk" -e "https.*aarch64_generic.ipk" -oE)"
    # for down_url in $(echo $mosdns_file_down); do
    #     wget ${down_url} -q -P packages
    #     mosdns_file=$(echo $down_url | awk -F "/" '{print $NF}' | cut -d _ -f 1)
    #     [[ "${?}" -eq "0" ]] || error_msg "[ $mosdns_file ] download failed!"
    #     echo -e "${INFO} The [ $mosdns_file ] is downloaded successfully."
    # done

    # Download luci-app-passwall
    if [[ ${op_sourse} == openwrt ]]; then
        passwall_api="https://api.github.com/repos/xiaorouji/openwrt-passwall/releases"
        passwall_file_down="$(curl -s ${passwall_api}/latest | grep "browser_download_url" | grep -e "https.*all.ipk" -e "https.*aarch64_cortex-a53.zip" -oE)"
        for down_url in $(echo $passwall_file_down); do
            wget ${down_url} -q -P packages
            if [[ ${down_url} == *.zip ]]; then
                passwall_packages=$(echo $down_url | awk -F "/" '{print $NF}')
                passwall_file=$(echo $passwall_packages | awk -F "_ipk" '{print $1}')
                unzip packages/${passwall_packages} -d zip_tmp
                rm packages/${passwall_packages}
                mv zip_tmp/* packages/ && rm -rf zip_tmp
            else
                passwall_file=$(echo $down_url | awk -F "/" '{print $NF}' | cut -d _ -f 1)
            fi
            [[ "${?}" -eq "0" ]] || error_msg "[ $passwall_file ] download failed!"
            echo -e "${INFO} The [ $passwall_file ] is downloaded successfully."
        done
    fi

    # Download luci-app-openclash
    if [[ ${op_sourse} == openwrt ]]; then
        openclash_api="https://api.github.com/repos/vernesong/Openclash/releases"
        openclash_file_down="$(curl -s ${openclash_api} | grep "browser_download_url" | grep -oE "https.*luci-app-openclash.*.ipk" | head -n 1)"
        wget ${openclash_file_down} -q -P packages
        openclash_file=$(echo $openclash_file_down | awk -F "/" '{print $NF}' | cut -d _ -f 1)
        [[ "${?}" -eq "0" ]] || error_msg "[ $openclash_file ] download failed!"
        echo -e "${INFO} The [ $openclash_file ] is downloaded successfully."
    fi

    # ......

    sync && sleep 3
    echo -e "${INFO} [ packages ] directory status: $(ls packages -l 2>/dev/null)"
}

# Add custom packages, lib, theme, app and i18n, etc.
custom_config() {
    cd ${imagebuilder_path}
    echo -e "${STEPS} Start adding custom config..."

    config_list=""
    if [[ -s "${custom_config_file}" ]]; then
        config_list="$(cat ${custom_config_file} 2>/dev/null | grep -E "^CONFIG_PACKAGE_.*=y" | sed -e 's/CONFIG_PACKAGE_//g' -e 's/=y//g' -e 's/[ ][ ]*//g' | tr '\n' ' ')"
        echo -e "${INFO} Custom config list: \n$(echo "${config_list}" | tr ' ' '\n')"
    else
        echo -e "${INFO} No custom config was added."
    fi
}

# Add custom files
# The FILES variable allows custom configuration files to be included in images built with Image Builder.
# The [ files ] directory should be placed in the Image Builder root directory where you issue the make command.
custom_files() {
    cd ${imagebuilder_path}
    echo -e "${STEPS} Start adding custom files..."

    if [[ -d "${custom_files_path}" ]]; then
        # Copy custom files
        [[ -d "files" ]] || mkdir -p files
        cp -rf ${custom_files_path}/* files

        sync && sleep 3
        echo -e "${INFO} [ files ] directory status: $(ls files -l 2>/dev/null)"
    else
        echo -e "${INFO} No customized files were added."
    fi
}

# Rebuild OpenWrt firmware
rebuild_firmware() {
    cd ${imagebuilder_path}
    echo -e "${STEPS} Start building OpenWrt with Image Builder..."

    # Selecting default packages, lib, theme, app and i18n, etc.

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
        uuidgen wget-ssl whereis which wpad-basic wwan xfs-fsck xfs-mkfs xz \
        xz-utils ziptool zoneinfo-asia zoneinfo-core zstd vim vim-runtime vim-help \
        \
        luci luci-base luci-compat luci-i18n-base-en luci-i18n-base-zh-cn luci-lib-base  \
        luci-lib-docker luci-lib-ip luci-lib-ipkg luci-lib-jsonc luci-lib-nixio  \
        luci-mod-admin-full luci-mod-network luci-mod-status luci-mod-system  \
        luci-proto-3g luci-proto-bonding luci-proto-ipip luci-proto-ipv6 luci-proto-ncm  \
        luci-proto-openconnect luci-proto-ppp luci-proto-qmi luci-proto-relay  \
        \
        luci-app-amlogic luci-i18n-amlogic-zh-cn \
        \
        v2ray-geoip v2ray-geosite \
        luci-app-passwall luci-i18n-passwall-zh-cn brook chinadns-ng dns2socks dns2tcp \
        hysteria microsocks naiveproxy shadowsocksr-libev-ssr-local shadowsocksr-libev-ssr-redir \
        shadowsocksr-libev-ssr-server shadowsocks-rust-sslocal shadowsocks-rust-ssserver \
        simple-obfs tcping trojan-go trojan-plus tuic-client v2ray-core v2ray-plugin xray-core xray-plugin \
        luci-app-openclash  dnsmasq-full ca-certificates ipset ip-full libcap libcap-bin \
        ruby ruby-yaml kmod-tun kmod-inet-diag kmod-nft-tproxy \
        ${config_list} \
        "

    # Rebuild firmware
    make image PROFILE="${target_profile}" PACKAGES="${my_packages}" FILES="files"

    sync && sleep 3
    echo -e "${INFO} [ openwrt/bin/targets/*/* ] directory status: $(ls bin/targets/*/* -l 2>/dev/null)"
    echo -e "${SUCCESS} The rebuild is successful, the current path: [ ${PWD} ]"
}

# Show welcome message
echo -e "${STEPS} Welcome to Rebuild OpenWrt Using the Image Builder."
[[ -x "${0}" ]] || error_msg "Please give the script permission to run: [ chmod +x ${0} ]"
[[ -z "${1}" ]] && error_msg "Please specify the OpenWrt Branch, such as [ ${0} openwrt:22.03.3 ]"
[[ "${1}" =~ ^[a-z]{3,}:[0-9]+ ]] || error_msg "Incoming parameter format <source:branch>: openwrt:22.03.3"
op_sourse="${1%:*}"
op_branch="${1#*:}"
echo -e "${INFO} Rebuild path: [ ${PWD} ]"
echo -e "${INFO} Rebuild Source: [ ${op_sourse} ], Branch: [ ${op_branch} ]"
echo -e "${INFO} Server space usage before starting to compile: \n$(df -hT ${make_path}) \n"
#
# Perform related operations
download_imagebuilder
adjust_settings
custom_packages
custom_config
custom_files
rebuild_firmware
#
# Show server end information
echo -e "Server space usage after compilation: \n$(df -hT ${make_path}) \n"
# All process completed
wait
