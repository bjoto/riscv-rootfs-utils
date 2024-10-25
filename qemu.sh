#!/bin/bash
# SPDX-FileCopyrightText: 2023 Rivos Inc.
#
# SPDX-License-Identifier: Apache-2.0

set -x
set -euo pipefail

reld=$(dirname "${BASH_SOURCE[0]}")
d=$(readlink -f $reld)

if [[ $1 == "acpi" ]]; then
    hwdesc=acpi
elif [[ $1 == "dt" ]]; then
    hwdesc=dt
else
    echo "arg1 has to be acpi or dt"
    exit 1
fi

cmdline="root=/dev/vda2 rw earlycon console=tty0 console=ttyS0 efi=debug"

qemu_rv64 () {
    local qemu_bios=$1
    local qemu_kernel=$2
    local qemu_cpu=$3
    local qemu_acpi=$4
    local qemu_aia=$5
    local qemu_image=$6
    local qemu_passthru=$7
    local qemu_cmdline=$8

    $d/qemu/qemu/build/inst/usr/local/bin/qemu-system-riscv64 \
        -no-reboot \
        -nographic \
        -machine virt,acpi=${qemu_acpi},aia=${qemu_aia} \
        -m 16G \
        -smp 8 \
        -cpu ${qemu_cpu} \
        -bios ${qemu_bios} \
        -kernel ${qemu_kernel} \
        -append "${qemu_cmdline}" \
        -object rng-random,filename=/dev/urandom,id=rng0 \
        -device virtio-rng-device,rng=rng0 \
        -drive if=none,file=${qemu_image},format=raw,id=hd0 \
        -device virtio-blk-pci,drive=hd0 \
        -virtfs local,path=${qemu_passthru},mount_tag=host0,security_model=mapped,id=host0
}

qemu_bios=$d/firmware/fw_dynamic.bin
# RVA23 plus zkr
qemu_cpu="rv64,b=on,zbc=off,v=true,vlen=256,elen=64,sscofpmf=on,svade=on,svinval=on,svnapot=on,svpbmt=on,zcb=on,zcmop=on,zfhmin=on,zicond=on,zimop=on,zkt=on,zvbb=on,zvfhmin=on,zvkt=on,zkr=on"
# qemu_cpu=max
qemu_image=$2
qemu_aia="aplic-imsic"
if [[ $hwdesc == "acpi" ]]; then
    qemu_acpi=on
    qemu_kernel_append="${cmdline} acpi=force"
    qemu_kernel=$d/firmware/rv64-u-boot-acpi.bin
else
    qemu_acpi=off
    qemu_kernel_append="${cmdline}"
    qemu_kernel=$d/firmware/rv64-u-boot.bin
fi
qemu_passthru=$3

qemu_rv64 ${qemu_bios} ${qemu_kernel} ${qemu_cpu} ${qemu_acpi} ${qemu_aia} ${qemu_image} ${qemu_passthru} "${qemu_kernel_append}"
