#!/bin/bash
# SPDX-FileCopyrightText: 2023 Rivos Inc.
#
# SPDX-License-Identifier: Apache-2.0

set -euo pipefail

reld=$(dirname "${BASH_SOURCE[0]}")
d=$(readlink -f $reld)

image=$1

if [[ ! -f $d/firmware/rv64-u-boot.bin ]]; then
    mkdir -p $d/firmware
    pushd $d/firmware > /dev/null
    $d/mkfirmware_rv64_uboot.sh
    tar xvf firmware_rv64_uboot_*.tar.xz
    popd > /dev/null
fi

qemu-system-riscv64 \
    -machine virt \
    -cpu rv64,v=true,vlen=256,elen=64,h=true,zbkb=on,zbkc=on,zbkx=on,zkr=on,zkt=on,svinval=on,svnapot=on,svpbmt=on \
    -nographic -m 16G -smp 8 -kernel $d/firmware/rv64-u-boot.bin \
    -device virtio-net-device,netdev=net0 -netdev user,hostfwd=tcp::10022-:22,id=net0,tftp=tftp \
    -drive file=$image,format=raw,if=virtio \
    -device virtio-rng-pci \
    -virtfs local,path=$PWD,mount_tag=host0,security_model=passthrough,id=host0

