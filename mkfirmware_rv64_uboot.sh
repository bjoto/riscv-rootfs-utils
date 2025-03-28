#!/bin/bash
# SPDX-FileCopyrightText: 2023 Rivos Inc.
#
# SPDX-License-Identifier: Apache-2.0

set -euo pipefail

d=$(dirname "${BASH_SOURCE[0]}")

tmp=$(mktemp -d -p "$PWD")

trap 'rm -rf "$tmp"' EXIT

git clone https://github.com/u-boot/u-boot.git $tmp -b v2025.04-rc3
make -C $tmp ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- qemu-riscv64_smode_defconfig

cat <<EOF >>$tmp/.config
CONFIG_CMD_KASLRSEED=y
CONFIG_CMD_RNG=y
CONFIG_EFI_RNG_PROTOCOL=y
CONFIG_VIRTIO_RNG=y
CONFIG_EFI_VARIABLE_FILE_STORE=n
CONFIG_EFI_VARIABLE_NO_STORE=n
CONFIG_BOOTCOMMAND="virtio scan; load virtio 0:1 \$kernel_addr_r /Image; fdt get value bootargs /chosen bootargs; bootefi \${kernel_addr_r} \${fdtcontroladdr}"
CONFIG_BOOTDELAY=0
EOF

make -C $tmp ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- olddefconfig
make -C $tmp ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- -j $(nproc)

mv $tmp/u-boot.bin $tmp/rv64-u-boot.bin

cd $tmp
short_sha1=`git rev-parse --short HEAD`
cd ..

name="firmware_rv64_uboot_${short_sha1}.tar.zst"
echo "${short_sha1}" > $tmp/uboot-sha1
rm -rf "$name"
tar -C "$tmp" -c -I 'zstd --ultra -20 -T0' -f "$name" ./rv64-u-boot.bin ./uboot-sha1
