#!/bin/bash
# SPDX-FileCopyrightText: 2023 Rivos Inc.
#
# SPDX-License-Identifier: Apache-2.0

# Builds and packages RV64 OpenSBI

set -euo pipefail

d=$(dirname "${BASH_SOURCE[0]}")

tmp=$(mktemp -d -p "$PWD")

trap 'rm -rf "$tmp"' EXIT

git clone https://github.com/riscv/opensbi.git -b v1.6 $tmp

make -C $tmp ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- PLATFORM_RISCV_XLEN=64 PLATFORM=generic -j $(nproc)

cd $tmp/build/platform/generic/firmware/
rm -rf $(ls |egrep -v '.bin$|.elf$')
short_sha1=`git rev-parse --short HEAD`
echo "${short_sha1}" > opensbi-sha1
cd -

name="firmware_rv64_opensbi_${short_sha1}.tar.zst"
rm -rf "$name"
tar -C "$tmp/build/platform/generic/firmware" -c -I 'zstd -T0 --ultra -20' -f "$name" .
