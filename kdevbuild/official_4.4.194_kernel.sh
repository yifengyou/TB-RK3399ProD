#!/bin/bash

set -euxo pipefail

WORKDIR=$(pwd)
export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y ca-certificates
apt-get update && apt-get install -y --no-install-recommends \
  build-essential ccache curl device-tree-compiler dosfstools fakeroot file flex gawk \
  gcc-aarch64-linux-gnu git gnupg jq libssl-dev locales lsb-release lzop make ncurses-dev \
  parted patch pigz python python3 python3-distutils python3-pip rsync sed sudo u-boot-tools \
  unzip wget xxd xz-utils zip binwalk zlib1g-dev squashfs-tools rar liblz4-tool genext2fs bc \
  htop openssh-client vim

localedef -i zh_CN -f UTF-8 zh_CN.UTF-8 || true
mkdir -p ${WORKDIR}/release

#==========================================================================#
#                        build uboot                                       #
#==========================================================================#
cd ${WORKDIR}
git clone https://github.com/yifengyou/rockchip-toybrick-u-boot u-boot.git
git clone https://github.com/yifengyou/rockchip-toybrick-rkbin.git rkbin
git clone https://github.com/yifengyou/rockchip-toybrick-linux-x86.git linux-x86

mkdir -p prebuilts/gcc/
mv linux-x86 prebuilts/gcc/

cd u-boot.git
./make.sh rk3399pro
cp *.img ${WORKDIR}/release/
ls -alh ${WORKDIR}/release/
md5sum ${WORKDIR}/release/*

#==========================================================================#
#                        build kernel                                      #
#==========================================================================#
cd ${WORKDIR}
git clone https://github.com/yifengyou/rockchip-toybrick-kernel kernel.git
cd kernel.git

# build kernel Image
make ARCH=arm64 \
  CROSS_COMPILE=aarch64-linux-gnu- \
  KBUILD_BUILD_USER="builder" \
  KBUILD_BUILD_HOST="kdevbuilder" \
  LOCALVERSION=-kdev \
  rockchip_linux_defconfig

make ARCH=arm64 \
  CROSS_COMPILE=aarch64-linux-gnu- \
  KBUILD_BUILD_USER="builder" \
  KBUILD_BUILD_HOST="kdevbuilder" \
  LOCALVERSION=-kdev \
  olddefconfig

# check kver
KVER=$(make LOCALVERSION=-kdev kernelrelease)
KVER="${KVER/kdev*/kdev}"
if [[ "$KVER" != *kdev ]]; then
  echo "ERROR: KVER does not end with 'kdev'"
  exit 1
fi
echo "KVER: ${KVER}"

make ARCH=arm64 \
  CROSS_COMPILE=aarch64-linux-gnu- \
  KBUILD_BUILD_USER="builder" \
  KBUILD_BUILD_HOST="kdevbuilder" \
  LOCALVERSION=-kdev \
  rk3399pro-toybrick-prod-linux.img \
  -j$(nproc)

make ARCH=arm64 \
  CROSS_COMPILE=aarch64-linux-gnu- \
  KBUILD_BUILD_USER="builder" \
  KBUILD_BUILD_HOST="kdevbuilder" \
  LOCALVERSION=-kdev \
  modules -j$(nproc)

make ARCH=arm64 \
  CROSS_COMPILE=aarch64-linux-gnu- \
  KBUILD_BUILD_USER="builder" \
  KBUILD_BUILD_HOST="kdevbuilder" \
  LOCALVERSION=-kdev \
  INSTALL_MOD_PATH=$(pwd)/kos \
  modules_install

# release kernel image
ls -alh arch/arm64/boot/Image
md5sum arch/arm64/boot/Image
cp -a arch/arm64/boot/Image ${WORKDIR}/release/

# release dtb
ls -alh arch/arm64/boot/dts/rockchip/rk3399pro-toybrick-prod-linux.dtb
md5sum arch/arm64/boot/dts/rockchip/rk3399pro-toybrick-prod-linux.dtb
cp -a arch/arm64/boot/dts/rockchip/rk3399pro-toybrick-prod-linux.dtb ${WORKDIR}/release/

# release config
cp .config ${WORKDIR}/release/config-4.4.194-kdev
ls -alh ${WORKDIR}/release/config-4.4.194-kdev
md5sum ${WORKDIR}/release/config-4.4.194-kdev

# release system map
cp System.map ${WORKDIR}/release/System.map-4.4.194-kdev
ls -alh ${WORKDIR}/release/System.map-4.4.194-kdev
md5sum ${WORKDIR}/release/System.map-4.4.194-kdev

# release kernel modules
if [ -d kos/lib/modules ]; then
  find kos -name "*.ko"
  ls -alh kos/lib/modules/
  tar -zcvf ${WORKDIR}/release/kos.tar.gz kos
fi

ls -alh ${WORKDIR}/release/
md5sum ${WORKDIR}/release/*

echo "Build completed successfully!"
exit 0
