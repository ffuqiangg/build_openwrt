#!/bin/bash

# Set default parameters
make_path="${PWD}"
openwrt_dir="openwrt"
imagebuilder_path="${make_path}/${openwrt_dir}"
custom_files_path="${make_path}/files"
custom_config_file="${make_path}/config/imagebuilder/config"
packages_json_file="${make_path}/config/imagebuilder/packages.json"

# Encountered a serious error, abort the script execution
error_msg() {
    echo -e "❌ ${1}"
    exit 1
}

# Downloading OpenWrt ImageBuilder
download_imagebuilder() {
    cd "${make_path}" || exit
    echo -e "🍺 Start downloading OpenWrt files..."

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
    echo -e "💬 [ ${make_path} ] directory status: $(ls . -l 2>/dev/null)"
}

# Adjust related files in the ImageBuilder directory
adjust_settings() {
    cd "${imagebuilder_path}" || exit
    echo -e "🍺 Start adjusting .config file settings..."

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
    cat > files/etc/uci-defaults/999-default-settings << EOF
#!/bin/bash

passwd root << EOI
password
password
EOI

echo -e "[34mopenwrt[0m build by ffuqiangg\n" > /etc/banner

sed -i -e '/ROOT1=/c ROOT1=\"720\"' -e '/ROOT2=/c ROOT2=\"720\"' /usr/sbin/openwrt-install-amlogic
mv -f /etc/profile.d/30-sysinfo.sh.tmp /etc/profile.d/30-sysinfo.sh

uci set network.lan.ipaddr='192.168.1.99'
uci commit network

exit0
EOF

    sync && sleep 3
    echo -e "💬 [ openwrt ] directory status: $(ls -al 2>/dev/null)"
}

# Add custom packages
# If there is a custom package or ipk you would prefer to use create a [ packages ] directory,
# If one does not exist and place your custom ipk within this directory.
custom_packages() {
    cd "${imagebuilder_path}" || exit
    echo -e "🍺 Start adding custom packages..."
    custom_packages_list=""
    github_api="https://api.github.com/repos"
    packages_list=$(jq -c 'keys' "${packages_json_file}" | sed -e 's/\[//' -e 's/\]//' -e 's/,/ /g')

    # Create a [ packages ] directory
    [[ -d "packages" ]] || mkdir packages

    # Download Packages
    for name in ${packages_list}; do
        packages_repo=$(jq -r ".${name}.packages_repo" "${packages_json_file}")
        jq_rule=$(jq -r ".${name}.jq_rule" "${packages_json_file}")
        packages_name=$(jq -r ".${name}.packages_name" "${packages_json_file}")
        packages_depends=$(jq -r ".${name}.packages_depends // \"\"" "${packages_json_file}")
        down_url=$(curl -s ${github_api}/"${packages_repo}"/releases | jq -r '.[].assets[].browser_download_url' | grep -E "${jq_rule}" | head -n 1)
        if ! wget "${down_url}" -q -P packages; then
            error_msg "[ ${packages_name} ] download failed!"
        fi
        echo -e "💬 The [ ${packages_name} ] is downloaded successfully."
        if [[ ${jq_rule} == *.zip ]];then
            unzip packages/"${jq_rule}" -d packages && rm packages/"${jq_rule}"
            packages_name=""
        fi
        custom_packages_list="${custom_packages_list} ${packages_name} ${packages_depends}"
    done

    sync && sleep 3
    echo -e "💬 [ packages ] directory status: $(ls packages -l 2>/dev/null)"
}

# Add custom packages, lib, theme, app and i18n, etc.
custom_config() {
    cd "${imagebuilder_path}" || exit
    echo -e "🍺 Start adding custom config..."

    config_list=""
    if [[ -s "${custom_config_file}" ]]; then
        config_list="$(grep <"${custom_config_file}" 2>/dev/null -E "^CONFIG_PACKAGE_.*=y" | sed -e 's/CONFIG_PACKAGE_//g' -e 's/=y//g' -e 's/[ ][ ]*//g' | tr '\n' ' ')"
        echo -e "💬 Custom config list: \n$(echo "${config_list}" | tr ' ' '\n')"
    else
        echo -e "💬 No custom config was added."
    fi
}

# Add custom files
# The FILES variable allows custom configuration files to be included in images built with Image Builder.
# The [ files ] directory should be placed in the Image Builder root directory where you issue the make command.
custom_files() {
    cd "${imagebuilder_path}" || exit
    echo -e "🍺 Start adding custom files..."

    if [[ -d "${custom_files_path}" ]]; then
        # Copy custom files
        [[ -d "files" ]] || mkdir -p files
        cp -rf "${custom_files_path}"/* files

        sync && sleep 3
        echo -e "💬 [ files ] directory status: $(ls files -l 2>/dev/null)"
    else
        echo -e "💬 No customized files were added."
    fi
}

# Rebuild OpenWrt firmware
rebuild_firmware() {
    cd "${imagebuilder_path}" || exit
    echo -e "🍺 Start building OpenWrt with Image Builder..."

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
        xz-utils ziptool zoneinfo-asia zoneinfo-core zstd vim htop\
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
    echo -e "💬 [ openwrt/bin/targets/*/* ] directory status: $(ls bin/targets/*/* -l 2>/dev/null)"
    echo -e "✔️ The rebuild is successful, the current path: [ ${PWD} ]"
}

# Show welcome message
echo -e "🍺 Welcome to Rebuild OpenWrt Using the Image Builder."
[[ -x "${0}" ]] || error_msg "Please give the script permission to run: [ chmod +x ${0} ]"
[[ -z "${1}" ]] && error_msg "Please specify the OpenWrt Branch, such as [ ${0} openwrt:22.03.3 ]"
[[ "${1}" =~ ^[a-z]{3,}:[0-9]+ ]] || error_msg "Incoming parameter format <source:branch>: openwrt:22.03.3"
op_source="${1%:*}"
op_branch="${1#*:}"
echo -e "💬 Rebuild path: [ ${PWD} ]"
echo -e "💬 Rebuild Source: [ ${op_source} ], Branch: [ ${op_branch} ]"
echo -e "💬 Server space usage before starting to compile: \n$(df -hT "${make_path}") \n"

# Perform related operations
download_imagebuilder
adjust_settings
custom_packages
custom_config
custom_files
rebuild_firmware

# Show server end information
echo -e "Server space usage after compilation: \n$(df -hT "${make_path}") \n"
# All process completed
wait
