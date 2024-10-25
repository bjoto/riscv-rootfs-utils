#!/bin/bash
# SPDX-FileCopyrightText: 2024 Rivos Inc.
#
# SPDX-License-Identifier: Apache-2.0

set -euo pipefail
shopt -s extglob

d=$(dirname "${BASH_SOURCE[0]}")

fw_rv64_opensbi=$(echo $d/firmware_rv64_opensbi_+([a-f0-9]).tar.zst)
fw_rv64_uboot=$(echo $d/firmware_rv64_uboot_+([a-f0-9]).tar.zst)
fw_rv64_uboot_acpi=$(echo $d/firmware_rv64_uboot_acpi_+([a-f0-9]).tar.zst)
qemu=$(echo $d/qemu_+([a-f0-9]).tar.zst)
rootfs=$(echo $d/rootfs_rv64_noble_*.tar)

mkdir -p $d/firmware
mkdir -p $d/qemu

if [[ ! -a $fw_rv64_opensbi ]]; then
    $d/mkfirmware_rv64_opensbi.sh
fi

if [[ ! -a $fw_rv64_uboot ]]; then
    $d/mkfirmware_rv64_uboot.sh
fi

if [[ ! -a $fw_rv64_uboot_acpi ]]; then
    $d/mkfirmware_rv64_uboot_acpi.sh
fi

if [[ ! -a $qemu ]]; then
    $d/mkqemu.sh
fi

if [[ ! -a $rootfs ]]; then
    $d/mkrootfs_rv64_ubuntu.sh
fi

if [[ ! -a $d/noble.img ]]; then
    $d/mkimage_rv64_uefi.sh $rootfs $d/noble.img
fi

tar -C $d/firmware -xf $fw_rv64_opensbi
tar -C $d/firmware -xf $fw_rv64_uboot
tar -C $d/firmware -xf $fw_rv64_uboot_acpi
tar -C $d/qemu -xf $qemu
