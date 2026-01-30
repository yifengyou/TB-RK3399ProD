#!/bin/bash

set -euxo pipefail

export DEBIAN_FRONTEND=noninteractive

echo "=== Updating APT ==="
apt-get update
apt-get install -y ca-certificates
apt-get update && apt-get install -y --no-install-recommends \
  build-essential ccache curl device-tree-compiler dosfstools fakeroot file flex gawk \
  gcc-aarch64-linux-gnu git gnupg jq libssl-dev locales lsb-release lzop make ncurses-dev \
  parted patch pigz python python3 python3-distutils python3-pip rsync sed sudo u-boot-tools \
  unzip wget xxd xz-utils zip binwalk zlib1g-dev squashfs-tools rar liblz4-tool genext2fs bc \
  htop openssh-client vim

# Set locale
localedef -i zh_CN -f UTF-8 zh_CN.UTF-8 || true

BUILDER_DIR="/workspace"
OUTPUT_DIR="${BUILDER_DIR}/output"
mkdir -p "$OUTPUT_DIR"

cd "${BUILDER_DIR}"
echo "=== Cloning repositories ==="
git clone --progress https://github.com/rockchip-toybrick/kernel.git kernel.git
git clone --progress https://github.com/rockchip-toybrick/u-boot.git u-boot.git
git clone --progress https://github.com/rockchip-toybrick/rkbin.git rkbin
git clone --progress https://github.com/rockchip-toybrick/linux-x86.git linux-x86

mkdir -p prebuilts/gcc/
mv linux-x86 prebuilts/gcc/

cd "${BUILDER_DIR}"
echo "=== Building U-Boot ==="
cd u-boot.git
./make.sh rk3399pro
cp *.img "$OUTPUT_DIR/"

cd "${BUILDER_DIR}"
echo "=== Building Kernel ==="
cd kernel.git
./make.sh linux prod
cp *.img "$OUTPUT_DIR/"

echo "=== Output ==="
ls -alh "$OUTPUT_DIR/"

echo "Build completed successfully!"
