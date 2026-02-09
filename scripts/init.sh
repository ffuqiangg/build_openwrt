sudo timedatectl set-timezone 'Asia/Shanghai'

echo "创建快捷命令"
bin_host="${HOME}/bin_host"
mkdir -p $bin_host

# --- 1. 定义 set_env (负责生产变量) ---
# 注意：这里使用 'EOF' 防止展开，逻辑更加纯粹
cat <<'EOF' > $bin_host/set_env
#!/bin/bash
# 这里的路径是容器内的视角
SYNC_FILE="${workdir}/.env_sync"
CI_ENV_FILE="${workdir}/ci_env"

p "set_env: $1 = $2"
export "$1"="$2"

# 1. 写入容器内持久化文件 (仅当目录存在且可写时)
# 宿主机运行时，/ci 目录不存在，这里会自动跳过，不报错
if [ -n "$workdir" ] && [ -d "$workdir" ]; then
    # 确保能写入 ci_env
    if [ -w "$workdir" ] || [ -w "$CI_ENV_FILE" ]; then
        echo "export $1=\"$2\"" >> "$CI_ENV_FILE"
    fi

    # 2. 写入同步文件 (这是自动化的关键)
    echo "$1=$2" >> "$SYNC_FILE"

    # 无论当前是 root 还是 runner，都将文件权限放开为 666 (rw-rw-rw-)
    # 这样宿主机脚本（runner用户）才有权限清空它
    chmod 666 "$SYNC_FILE" 2>/dev/null || true
fi

# 3. 兼容逻辑：宿主机 fallback
# 如果是在宿主机运行，且 GITHUB_ENV 存在，直接写入
if [ -z "$workdir" ] && [ -n "$GITHUB_ENV" ]; then
    echo "$1=$2" >> "$GITHUB_ENV"
fi
EOF

# --- 2. 定义 p (打印日志，无需改动) ---
cat <<'EOF' > $bin_host/p
#!/bin/bash
echo "    >> $*"
EOF

# --- 3. 定义 d (Runner 身份执行 + 自动同步变量) ---
cat <<'EOF' > $bin_host/d
#!/bin/bash
p "runner@buildos: $*"
docker exec -u runner -e BASH_ENV=${workdir}/ci_env buildos bash -c "$*"
EXIT_CODE=$?

# === 自动化同步逻辑开始 ===
# 这里的路径是宿主机视角
HOST_SYNC_FILE="${workdir_host}/.env_sync"
if [ -f "$HOST_SYNC_FILE" ] && [ -s "$HOST_SYNC_FILE" ]; then
    # 追加到 GitHub 环境
    cat "$HOST_SYNC_FILE" >> $GITHUB_ENV
    # 清空文件，防止重复写入
    > "$HOST_SYNC_FILE"
fi
# === 自动化同步逻辑结束 ===

exit $EXIT_CODE
EOF

# --- 4. 定义 dr (Root 身份执行 + 自动同步变量) ---
cat <<'EOF' > $bin_host/dr
#!/bin/bash
p "root@buildos: $*"
docker exec -u root -e BASH_ENV=${workdir}/ci_env buildos bash -c "$*"
EXIT_CODE=$?

# === 自动化同步逻辑开始 ===
HOST_SYNC_FILE="${workdir_host}/.env_sync"
if [ -f "$HOST_SYNC_FILE" ] && [ -s "$HOST_SYNC_FILE" ]; then
    cat "$HOST_SYNC_FILE" >> $GITHUB_ENV
    > "$HOST_SYNC_FILE"
fi
# === 自动化同步逻辑结束 ===

exit $EXIT_CODE
EOF

# --- 5. clone 命令---
cat <<'EOF' > $bin_host/clone
#!/bin/bash
if [ $# -lt 2 ]; then
    echo "用法: clone <branch> <repo_url> <target_dir>" >&2
    return 1
fi
p "浅克隆: $2 (branch: $1) $3"
git clone -q --filter=blob:none --single-branch -b "$1" "$2" "$3"
EOF

sed -i "s/buildos/${build_os}/g" $bin_host/{dr,d}

chmod +x $bin_host/*
echo "$bin_host" >> $GITHUB_PATH
export PATH="$bin_host:$PATH"


p "打印可用空间"
df -h



p "准备 ${build_os^^}"
. set_env "workdir" "/ci"  # 必须使用 . set_env ，否则变量不会在当前 shell 生效
. set_env "workdir_host" "/mnt${workdir}"
. set_env "ffdir" "${workdir}/ffos"

sudo mkdir ${workdir_host} && sudo chown -R runner:runner ${workdir_host}

if [ "${build_os}" == 'ubuntu' ]; then
    docker_image='ubuntu:22.04'
elif [ "${build_os}" == 'cachyos' ]; then
    docker_image='cachyos/cachyos-v3'
fi

# tail -f /dev/null: 保持容器运行
GH_ENV_DIR=$(dirname "$GITHUB_ENV")
GH_PATH_DIR=$(dirname "$GITHUB_PATH")
docker pull ${docker_image}
docker run -d --name ${build_os} \
    -v ${workdir_host}:${workdir} \
    -v "$bin_host:/usr/local/bin_host" \
    -e PATH="/usr/local/bin_host:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
    -e workdir="${workdir}" \
    -e workdir_host="${workdir_host}" \
    -e ffdir="${ffdir}" \
    -e BASH_ENV="${workdir}/ci_env" \
    -w ${workdir} \
    ${docker_image} tail -f /dev/null


p "初始化容器环境文件"
# 先创建文件并授权，这样容器内的 set_env 才能写入
dr "touch ${workdir}/ci_env"
dr "chmod 777 ${workdir}/ci_env"
# 将初始变量写入容器的持久化文件，供后续 exec 使用
dr '. set_env workdir "${workdir}"'
dr '. set_env workdir_host "${workdir_host}"'
dr '. set_env ffdir "${ffdir}"'


p "安装依赖"
if [ "${build_os}" == 'ubuntu' ]; then
    dr apt-get -y -qq update
    dr DEBIAN_FRONTEND=noninteractive \
        apt-get -y -qq install ack antlr3 asciidoc autoconf automake autopoint binutils \
        bison build-essential bzip2 ccache clang cmake cpio curl device-tree-compiler \
        ecj fastjar flex gawk gettext gcc-multilib g++-multilib git gnutls-dev gperf haveged \
        help2man intltool lib32gcc-s1 libc6-dev-i386 libelf-dev libglib2.0-dev libgmp3-dev \
        libltdl-dev libmpc-dev libmpfr-dev libncurses-dev libpython3-dev libreadline-dev libssl-dev \
        libtool libyaml-dev libz-dev lld llvm llvm-dev lrzsz mkisofs msmtp nano ninja-build p7zip p7zip-full \
        patch pkgconf python3 python3-pip python3-ply python3-docutils python3-pyelftools qemu-utils \
        re2c rsync scons squashfs-tools subversion swig texinfo uglifyjs upx-ucl unzip vim wget \
        xmlto xxd zlib1g-dev zstd sudo

    p "确保用户一致并配置 sudo"
    dr "mkdir -p /etc/sudoers.d;"
    dr "groupadd -g 1001 runner || true;"
    dr "useradd -u 1001 -g 1001 -m -s /bin/bash runner;"
    dr "echo 'runner ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/runner;"
    dr "chmod 0440 /etc/sudoers.d/runner;"
    dr "chown -R runner:runner /home/runner"
elif [ "${build_os}" == 'cachyos' ]; then
    dr pacman -Syu --noconfirm
    dr pacman -S --needed --noconfirm base-devel asciidoc autoconf automake binutils bison \
        bzip2 ccache llvm clang cmake cpio curl dtc eclipse-ecj fastjar flex gawk gettext \
        gcc-multilib git gnutls gperf haveged help2man intltool lib32-gcc-libs lib32-glibc \
        libelf glib2 gmp libtool libmpc mpfr ncurses python python-pip python-ply \
        python-docutils python-pyelftools qemu-img re2c rsync scons squashfs-tools \
        subversion swig texinfo uglify-js upx unzip wget xmlto xxd zstd 7zip \
        paru sudo shadow jq ninja python-setuptools python-pyelftools bc libxslt openssl time \
        util-linux which perl-extutils-makemaker fuse2 less tree
        # 不要添加zlib，会冲突

    p "确保用户一致并配置 sudo"
    dr "groupadd -g $(id -g runner) runner || true;"
    dr "useradd -u $(id -u runner) -g $(id -g runner) -m -s /bin/bash runner;"
    dr "echo 'runner ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/runner;"
    dr "chmod 0440 /etc/sudoers.d/runner;"
    dr "chown -R runner:runner /home/runner"
fi



p "d 命令已可用"

p "将常用仓库写入环境变量"
d '
    . set_env "openwrt_repo" "https://github.com/openwrt/openwrt"
    . set_env "openwrt_pkg_repo" "https://github.com/openwrt/packages"
    . set_env "openwrt_luci_repo" "https://github.com/openwrt/luci"
    . set_env "immortalwrt_repo" "https://github.com/immortalwrt/immortalwrt"
    . set_env "immortalwrt_pkg_repo" "https://github.com/immortalwrt/packages"
    . set_env "immortalwrt_luci_repo" "https://github.com/immortalwrt/luci"
    . set_env "lede_repo" "https://github.com/coolsnowwolf/lede"
    . set_env "lede_pkg_repo" "https://github.com/coolsnowwolf/packages"
    . set_env "lede_luci_repo" "https://github.com/coolsnowwolf/luci"
    . set_env "istoreos_repo" "https://github.com/istoreos/istoreos"
    . set_env "lienol_pkg_repo" "https://github.com/Lienol/openwrt-package"
    . set_env "passwall_luci_repo" "https://github.com/xiaorouji/openwrt-passwall"
    . set_env "passwall_pkg_repo" "https://github.com/xiaorouji/openwrt-passwall-packages"
    . set_env "dockerman_repo" "https://github.com/lisaac/luci-app-dockerman"
    . set_env "diskman_repo" "https://github.com/lisaac/luci-app-diskman"
    . set_env "docker_lib_repo" "https://github.com/lisaac/luci-lib-docker"
    . set_env "openwrt_mosdns_repo" "https://github.com/QiuSimons/openwrt-mos"
    . set_env "sbwml_mosdns_repo" "https://github.com/sbwml/luci-app-mosdns"
    . set_env "v2ray_geodata_repo" "https://github.com/sbwml/v2ray-geodata"
    . set_env "openclash_repo" "https://github.com/vernesong/OpenClash"
    . set_env "nikki_repo" "https://github.com/nikkinikki-org/OpenWrt-nikki"
    . set_env "momo_repo" "https://github.com/nikkinikki-org/OpenWrt-momo"
    . set_env "amlogic_repo" "https://github.com/ophub/luci-app-amlogic"
    . set_env "daed_repo" "https://github.com/QiuSimons/luci-app-daed"
    . set_env "helloworld_repo" "https://github.com/sbwml/openwrt_helloworld"
    . set_env "openwrt_add_repo" "https://github.com/QiuSimons/OpenWrt-Add"
    . set_env "sbwml_pkgs_repo" "https://github.com/sbwml/openwrt_pkgs"
    . set_env "v2raya_repo" "https://github.com/zxlhhyccc/luci-app-v2raya"
    . set_env "autocore_arm_repo" "https://github.com/sbwml/autocore-arm"
    . set_env "homeproxy_repo" "https://github.com/immortalwrt/homeproxy"
'

[ "${build_os}" == 'cachyos' ] && d paru --noconfirm -S ack antlr3

p "复制仓库到容器内 ${ffdir}"
cp -r $GITHUB_WORKSPACE ${workdir_host}/ffos

p "外部脚本结束"
