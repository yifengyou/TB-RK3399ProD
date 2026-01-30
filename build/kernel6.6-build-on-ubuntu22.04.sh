#!/bin/bash
set -euxo pipefail

# === 1. 初始化环境 ===
export DEBIAN_FRONTEND=noninteractive

echo "=== Updating APT ==="
apt-get update
apt-get install -y ca-certificates
apt-get install -y --no-install-recommends \
  build-essential \
  ccache \
  curl \
  device-tree-compiler \
  dosfstools \
  fakeroot \
  file \
  flex \
  gawk \
  gcc-aarch64-linux-gnu \
  git \
  gnupg \
  jq \
  libssl-dev \
  locales \
  lsb-release \
  lzop \
  make \
  ncurses-dev \
  parted \
  patch \
  pigz \
  python \
  python3 \
  python3-distutils \
  python3-pip \
  rsync \
  sed \
  sudo \
  u-boot-tools \
  unzip \
  wget \
  xxd \
  xz-utils \
  zip \
  binwalk \
  zlib1g-dev \
  squashfs-tools \
  rar \
  liblz4-tool \
  genext2fs \
  bc \
  htop \
  openssh-client

# Set locale
localedef -i zh_CN -f UTF-8 zh_CN.UTF-8 || true

# === 2. 创建工作目录 ===
BUILDER_DIR="/build"
OUTPUT_DIR="${BUILDER_DIR}/output"
mkdir -p "$OUTPUT_DIR"

cd "${BUILDER_DIR}"
# === 3. 克隆仓库 ===
echo "=== Cloning repositories ==="
git clone --progress https://github.com/ophub/linux-6.6.y.git linux-6.6.y.git
git clone --progress https://github.com/rockchip-toybrick/u-boot.git u-boot.git
git clone --progress https://github.com/rockchip-toybrick/rkbin.git rkbin
git clone --progress https://github.com/rockchip-toybrick/linux-x86.git linux-x86

mkdir -p prebuilts/gcc/
mv linux-x86 prebuilts/gcc/

cd "${BUILDER_DIR}"
# === 4. 编译 U-Boot ===
echo "=== Building U-Boot ==="
cd u-boot.git
./make.sh rk3399pro
cp *.img "$OUTPUT_DIR/"

cd "${BUILDER_DIR}"
# === 5. 编译 Kernel ===
echo "=== Building Kernel ==="
cd linux-6.6.y.git
cp -a ${BUILDER_DIR}/linux-6.6.y.git/kernel-6.6/config-6.6 .config
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- olddefconfig
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j`nproc` Image
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j`nproc` modules
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j`nproc` dtbs
cp arch/arm64/boot/Image "$OUTPUT_DIR/"

echo "=== Output ==="
ls -alh "$OUTPUT_DIR/"

echo "Build completed successfully!"

