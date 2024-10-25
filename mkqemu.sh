#!/bin/bash
# SPDX-FileCopyrightText: 2024 Rivos Inc.
#
# SPDX-License-Identifier: Apache-2.0

set -x
set -euo pipefail

d=$(dirname "${BASH_SOURCE[0]}")

tmp=$(mktemp -d -p "$PWD")

trap 'rm -rf "$tmp"' EXIT

pushd $tmp
git clone https://gitlab.com/qemu-project/qemu.git
cd qemu
git checkout -b v9.1.1
git submodule update --init
mkdir inst
mkdir build
cd build
../configure --target-list=riscv64-softmmu,riscv32-softmmu
export DESTDIR="./inst"
ninja install

short_sha1=`git rev-parse --short HEAD`
echo "${short_sha1}" > $d/inst/qemu-system-riscv-sha1
name="qemu_${short_sha1}.tar.zst"

popd
tar -C "$tmp" -c -I 'zstd --ultra -20 -T0' -f "$name" ./qemu/build/inst
