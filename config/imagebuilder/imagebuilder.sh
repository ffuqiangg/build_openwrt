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

# Encountered a serious error, abort the script execution
error_msg() {
    echo -e "${ERROR} ${1}"
    exit 1
}

# Downloading OpenWrt ImageBuilder
download_imagebuilder() {
    cd "${make_path}" || exit
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
    download_file="https://downloads.${op_source}.org/releases/${op_branch}/targets/${target_system}/${op_source}-imagebuilder-${op_branch}-${target_name}.Linux-x86_64.tar.xz"
    if ! wget -q "${download_file}"; then
        error_msg "Wget download failed: [ ${download_file} ]"
    fi

    # Unzip and change the directory name
    tar -xJf ./*-imagebuilder-* && sync && rm -f ./*-imagebuilder-*.tar.xz
    mv -f ./*-imagebuilder-* ${openwrt_dir}

    sync && sleep 3
    echo -e "${INFO} [ ${make_path} ] directory status: $(ls . -l 2>/dev/null)"
}

# Adjust related files in the ImageBuilder directory
adjust_settings() {
    cd "${imagebuilder_path}" || exit
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
    [[ -d "files" ]] || mkdir -p files/etc/uci-defaults
    if [[ ${op_source} == openwrt ]]; then
        cat >files/etc/uci-defaults/999-default-settings <<EOF
#!/bin/bash

echo "╭────────────────────────╮" > /etc/banner
echo "│[36m  ┌─┐┌─┐┌─┐┌─┐╷╷╷┌─╶┬╴  [0m│" >> /etc/banner
echo "│[36m  └─┘╵‾ └─ ╵ ╵└┴┘╵  ╵   [0m│" >> /etc/banner
echo "╰────────────────────────╯" >> /etc/banner

sed -i -e '/ROOT1=/c ROOT1=\"720\"' -e '/ROOT2=/c ROOT2=\"720\"' /usr/sbin/openwrt-install-amlogic
rm -f /etc/profile.d/30-sysinfo.sh

exit0
EOF
    elif [[ ${op_source} == immortalwrt ]]; then
        cat >files/etc/uci-defaults/999-default-settings <<EOF
#!/bin/bash

echo "╭────────────────────────────────╮" > /etc/banner
echo "│[36m  ╷┌┬┐┌┬┐┌─┐┌─╶┬╴┌─┐╷ ╷╷╷┌─╶┬╴  [0m│" >> /etc/banner
echo "│[36m  ╵╵╵╵╵╵╵└─┘╵  ╵ ╵‾╵└─└┴┘╵  ╵   [0m│" >> /etc/banner
echo "╰────────────────────────────────╯" >> /etc/banner

sed -i -e '/ROOT1=/c ROOT1=\"720\"' -e '/ROOT2=/c ROOT2=\"720\"' /usr/sbin/openwrt-install-amlogic
rm -f /etc/profile.d/30-sysinfo.sh

exit0
EOF
    fi

    sync && sleep 3
    echo -e "${INFO} [ openwrt ] directory status: $(ls -al 2>/dev/null)"
}

# Add custom packages
# If there is a custom package or ipk you would prefer to use create a [ packages ] directory,
# If one does not exist and place your custom ipk within this directory.
custom_packages() {
    cd "${imagebuilder_path}" || exit
    echo -e "${STEPS} Start adding custom packages..."
    custom_packages_list=""
    github_api="https://api.github.com/repos"

    # Create a [ packages ] directory
    [[ -d "packages" ]] || mkdir packages

    # Download luci-app-amlogic
    amlogic_repo="ophub/luci-app-amlogic"
    amlogic_file_down="$(curl -s ${github_api}/${amlogic_repo}/releases/latest | grep "browser_download_url" | grep -oE "https.*all.ipk")"
    for down_url in ${amlogic_file_down}; do
        amlogic_file=$(echo "${down_url}" | awk -F "/" '{print $NF}' | cut -d _ -f 1)
        if ! wget "${down_url}" -q -P packages; then
            error_msg "[ ${amlogic_file} ] download failed!"
        fi
        echo -e "${INFO} The [ ${amlogic_file} ] is downloaded successfully."
    done
    custom_packages_list="${custom_packages_list} luci-app-amlogic luci-i18n-amlogic-zh-cn"

    # Download luci-app-mosdns
    mosdns_repo="sbwml/luci-app-mosdns"
    mosdns_file_down="$(curl -s ${github_api}/${mosdns_repo}/releases/latest | grep "browser_download_url" | grep -e "https.*all.ipk" -e "https.*aarch64_cortex-a53.ipk" -oE)"
    for down_url in ${mosdns_file_down}; do
        mosdns_file=$(echo "${down_url}" | awk -F "/" '{print $NF}' | cut -d _ -f 1)
        if ! wget "${down_url}" -q -P packages; then
            error_msg "[ $mosdns_file ] download failed!"
        fi
        echo -e "${INFO} The [ $mosdns_file ] is downloaded successfully."
    done
    custom_packages_list="${custom_packages_list} luci-app-mosdns luci-i18n-mosdns-zh-cn"

    # Download luci-app-passwall2
    if [[ ${op_source} == openwrt ]]; then
        passwall_repo="xiaorouji/openwrt-passwall2"
        passwall_file_down="$(curl -s ${github_api}/${passwall_repo}/releases/latest | grep "browser_download_url" | grep -e "https.*all.ipk" -e "https.*aarch64_cortex-a53.zip" -oE)"
        for down_url in ${passwall_file_down}; do
            passwall_file=$(echo "${down_url}" | awk -F "/" '{print $NF}' | cut -d _ -f -2)
            if ! wget "${down_url}" -q -P packages; then
                error_msg "[ $passwall_file ] download failed!"
            fi
            echo -e "${INFO} The [ $passwall_file ] is downloaded successfully."
            if [[ ${down_url} == *.zip ]]; then
                passwall_packages=$(echo "${down_url}" | awk -F "/" '{print $NF}')
                unzip -q packages/"${passwall_packages}" -d zip_tmp
                rm packages/"${passwall_packages}" zip_tmp/v2ray-geo*.ipk
                mv zip_tmp/* packages/ && rm -rf zip_tmp
            fi
        done
        custom_packages_list="${custom_packages_list} luci-app-passwall2 luci-i18n-passwall2-zh-cn"
    fi

    # Download luci-app-openclash
    if [[ ${op_source} == openwrt ]]; then
        openclash_repo="vernesong/Openclash"
        openclash_file_down="$(curl -s ${github_api}/${openclash_repo}/releases | grep "browser_download_url" | grep -oE "https.*luci-app-openclash.*.ipk" | head -n 1)"
        openclash_file=$(echo "${openclash_file_down}" | awk -F "/" '{print $NF}' | cut -d _ -f 1)
        if ! wget "${openclash_file_down}" -q -P packages; then
            error_msg "[ $openclash_file ] download failed!"
        fi
        echo -e "${INFO} The [ $openclash_file ] is downloaded successfully."
        custom_packages_list="${custom_packages_list} luci-app-openclash -dnsmasq"
    elif [[ ${op_source} == immortalwrt ]]; then
        custom_packages_list="${custom_packages_list} luci-app-openclash -dnsmasq"
    fi

    # Download luci-app-vlmcsd KMS
    if [[ ${op_source} == openwrt ]]; then
        luci_vlmcsd_repo="cokebar/luci-app-vlmcsd"
        luci_vlmcsd_file_down="$(curl -s ${github_api}/${luci_vlmcsd_repo}/releases/latest | grep "browser_download_url" | grep -oE "https.*luci-app-vlmcsd.*.ipk")"
        luci_vlmcsd_file=$(echo "${luci_vlmcsd_file_down}" | awk -F "/" '{print $NF}' | cut -d _ -f 1)
        if ! wget "${luci_vlmcsd_file_down}" -q -P packages; then
            error_msg "[ $luci_vlmcsd_file ] download failed!"
        fi
        echo -e "${INFO} The [ $luci_vlmcsd_file ] is downloaded successfully."

        vlmcsd_url="https://github.com/cokebar/openwrt-vlmcsd/tree/gh-pages"
        vlmcsd_file="$(curl -s "${vlmcsd_url}" | grep -oP "vlmcsd_.*?aarch64_cortex-a53.ipk" | sort -rV | head -n 1)"
        vlmcsd_file_down="${vlmcsd_url/tree/raw}/${vlmcsd_file}"
        if ! wget "${vlmcsd_file_down}" -q -P packages; then
            error_msg "[ vlmcsd ] download failed!"
        fi
        echo -e "${INFO} The [ vlmcsd ] is downloaded successfully."
        custom_packages_list="${custom_packages_list} luci-app-vlmcsd"
    elif [[ ${op_source} == immortalwrt ]]; then
        custom_packages_list="${custom_packages_list} luci-app-vlmcsd"
    fi

    # Download autocore
    if [[ ${op_source} == openwrt ]]; then
        autocore_url="https://downloads.immortalwrt.org/snapshots/targets/armsr/armv8/packages/"
        autocore_file="$(curl -s "${autocore_url}" | grep -oP "autocore.*?.ipk" | head -n 1)"
        autocore_file_down="${autocore_url}${autocore_file}"
        if ! wget "${autocore_file_down}" -q -P packages; then
            error_msg "[ autocore ] download failed!"
        fi
        echo -e "${INFO} The [ autocore ] is downloaded successfully."
         custom_packages_list="${custom_packages_list} autocore"
    elif [[ ${op_source} == immortalwrt ]]; then
        custom_packages_list="${custom_packages_list} autocore"
    fi

    # ......

    sync && sleep 3
    echo -e "${INFO} [ packages ] directory status: $(ls packages -l 2>/dev/null)"
}

# Add custom packages, lib, theme, app and i18n, etc.
custom_config() {
    cd "${imagebuilder_path}" || exit
    echo -e "${STEPS} Start adding custom config..."

    config_list=""
    if [[ -s "${custom_config_file}" ]]; then
        config_list="$(< "${custom_config_file}" 2>/dev/null grep -E "^CONFIG_PACKAGE_.*=y" | sed -e 's/CONFIG_PACKAGE_//g' -e 's/=y//g' -e 's/[ ][ ]*//g' | tr '\n' ' ')"
        echo -e "${INFO} Custom config list: \n$(echo "${config_list}" | tr ' ' '\n')"
    else
        echo -e "${INFO} No custom config was added."
    fi
}

# Add custom files
# The FILES variable allows custom configuration files to be included in images built with Image Builder.
# The [ files ] directory should be placed in the Image Builder root directory where you issue the make command.
custom_files() {
    cd "${imagebuilder_path}" || exit
    echo -e "${STEPS} Start adding custom files..."

    if [[ -d "${custom_files_path}" ]]; then
        # Copy custom files
        [[ -d "files" ]] || mkdir -p files
        cp -rf "${custom_files_path}"/* files

        sync && sleep 3
        echo -e "${INFO} [ files ] directory status: $(ls files -l 2>/dev/null)"
    else
        echo -e "${INFO} No customized files were added."
    fi
}

# Rebuild OpenWrt firmware
rebuild_firmware() {
    cd "${imagebuilder_path}" || exit
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
        xz-utils ziptool zoneinfo-asia zoneinfo-core zstd vim-fuller \
        \
        luci luci-base luci-compat luci-i18n-base-en luci-i18n-base-zh-cn luci-lib-base  \
        luci-lib-docker luci-lib-ip luci-lib-ipkg luci-lib-jsonc luci-lib-nixio  \
        luci-mod-admin-full luci-mod-network luci-mod-status luci-mod-system  \
        luci-proto-3g luci-proto-bonding luci-proto-ipip luci-proto-ipv6 luci-proto-ncm  \
        luci-proto-openconnect luci-proto-ppp luci-proto-qmi luci-proto-relay  \
        \
        ${custom_packages_list} ${config_list} \
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
op_source="${1%:*}"
op_branch="${1#*:}"
echo -e "${INFO} Rebuild path: [ ${PWD} ]"
echo -e "${INFO} Rebuild Source: [ ${op_source} ], Branch: [ ${op_branch} ]"
echo -e "${INFO} Server space usage before starting to compile: \n$(df -hT "${make_path}") \n"
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
echo -e "Server space usage after compilation: \n$(df -hT "${make_path}") \n"
# All process completed
wait
