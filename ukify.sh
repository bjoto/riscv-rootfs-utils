#!/bin/bash
# SPDX-FileCopyrightText: 2023 Rivos Inc.
#
# SPDX-License-Identifier: Apache-2.0

set -euo pipefail

d=$(dirname "${BASH_SOURCE[0]}")

# assumes:
#
# git clone https://github.com/systemd/systemd.git
# cd systemd/src/ukify
# python -m venv venv
# . ./venv/bin/activate
# pip install pefile
#

stub=$1
kernel=$2
cmdline=$3
output=$4

. ~/src/systemd/src/ukify/./venv/bin/activate
~/src/systemd/src/ukify/ukify.py \
    build \
    --efi-arch riscv64 \
    --stub=$stub \
    --linux=$kernel \
    --cmdline="$cmdline" \
    -o $output

    #--initrd=/home/bjorn/src/riscv-rootfs-utils/up/boot/initrd.img-6.5.0-5-riscv64 
