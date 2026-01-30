#!/bin/bash
set -euxo pipefail

# === 1. 初始化环境 ===
export DEBIAN_FRONTEND=noninteractive

echo "=== Updating APT ==="
apt-get update
apt-get install -y ca-certificates
apt-get install -y --no-install-recommends \
    acl aptly aria2 axel bc binfmt-support binutils-aarch64-linux-gnu bison bsdextrautils \
    btrfs-progs build-essential busybox ca-certificates ccache clang coreutils cpio \
    crossbuild-essential-arm64 cryptsetup curl debian-archive-keyring debian-keyring debootstrap \
    device-tree-compiler dialog dirmngr distcc dosfstools dwarves e2fsprogs expect f2fs-tools fakeroot \
    fdisk file flex gawk gcc-aarch64-linux-gnu gcc-arm-linux-gnueabi gdisk git gnupg gzip htop \
    imagemagick jq kmod lib32ncurses-dev lib32stdc++6 libbison-dev libc6-dev-armhf-cross libc6-i386 \
    libcrypto++-dev libelf-dev libfdt-dev libfile-fcntllock-perl libfl-dev libfuse-dev \
    libgcc-12-dev-arm64-cross libgmp3-dev liblz4-tool libmpc-dev libncurses-dev libncurses5 \
    libncurses5-dev libncursesw5-dev libpython2.7-dev libpython3-dev libssl-dev libusb-1.0-0-dev \
    linux-base lld llvm locales lsb-release lz4 lzma lzop make mtools ncurses-base ncurses-term \
    nfs-kernel-server ntpdate openssl p7zip p7zip-full parallel parted patch patchutils pbzip2 pigz \
    pixz pkg-config pv python2 python2-dev python3 python3-dev python3-distutils python3-pip \
    python3-setuptools python-is-python3 qemu-user-static rar rdfind rename rsync sed squashfs-tools \
    sudo swig tar tree u-boot-tools udev unzip util-linux uuid uuid-dev uuid-runtime vim wget whiptail \
    xfsprogs xsltproc xxd xz-utils zip zlib1g-dev zstd binwalk ripgrep

# Set locale
localedef -i zh_CN -f UTF-8 zh_CN.UTF-8 || true

# === 2. 创建工作目录 ===
BUILDER_DIR="/workspace"
OUTPUT_DIR="${BUILDER_DIR}/output"
mkdir -p "$OUTPUT_DIR"

cd "${BUILDER_DIR}"
# === 3. 克隆仓库 ===
echo "=== Cloning repositories ==="
git clone --progress https://github.com/ophub/linux-6.6.y.git linux-6.6.y.git
# git clone --progress https://github.com/rockchip-toybrick/u-boot.git u-boot.git
# git clone --progress https://github.com/rockchip-toybrick/rkbin.git rkbin
# git clone --progress https://github.com/rockchip-toybrick/linux-x86.git linux-x86
# mkdir -p prebuilts/gcc/
# mv linux-x86 prebuilts/gcc/

#cd "${BUILDER_DIR}"
## === 4. 编译 U-Boot ===
#echo "=== Building U-Boot ==="
#cd u-boot.git
#./make.sh rk3399pro
#cp *.img "$OUTPUT_DIR/"

cd "${BUILDER_DIR}"
# === 5. 编译 Kernel ===
echo "=== Building Kernel ==="
cd linux-6.6.y.git
cp -a ${BUILDER_DIR}/kernel-6.6/config-6.6 .config
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- olddefconfig
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j`nproc` Image
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j`nproc` modules
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j`nproc` dtbs
cp arch/arm64/boot/Image "$OUTPUT_DIR/"

echo "=== Output ==="
ls -alh "$OUTPUT_DIR/"

echo "Build completed successfully!"

