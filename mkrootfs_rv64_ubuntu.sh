#!/bin/bash
# SPDX-FileCopyrightText: 2023 Rivos Inc.
#
# SPDX-License-Identifier: Apache-2.0

set -euo pipefail

d=$(dirname "${BASH_SOURCE[0]}")

distro=${1:-mantic}

packages=(
    automake
    bc
    bison
    build-essential
    build-essential
    bzip2
    ca-certificates
    cpio
    debianutils
    fakeroot
    flex
    gawk
    gcc
    git
    gzip
    kmod
    libarchive-tools
    libc6-dev
    libipc-run-perl
    libklibc-dev
    libssl-dev
    libtool
    linux-image-generic
    linux-libc-dev
    make
    numactl
    openssl
    patch
    python-is-python3
    rsync
    rsync
    ruby
    ruby-dev
    systemd-boot-efi
    time
    wget
)
packages=$(IFS=, && echo "${packages[*]}")

name="rootfs_rv64_${distro}_$(date +%Y.%m.%d).tar"

mmdebstrap --include="$packages" \
           --architecture=riscv64 \
	   --components="main restricted multiverse universe" \
	   --customize-hook=$d/systemd-debian-customize-hook.sh \
	   --skip=cleanup/reproducible \
           "${distro}" \
           "${name}"

