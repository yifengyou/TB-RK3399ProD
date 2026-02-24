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
./make.sh linux prod
cp *.img ${WORKDIR}/release/
ls -alh ${WORKDIR}/release/
md5sum ${WORKDIR}/release/*

echo "Build completed successfully!"
exit 0