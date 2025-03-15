#!/bin/bash
# SPDX-FileCopyrightText: 2023 Rivos Inc.
#
# SPDX-License-Identifier: Apache-2.0

set -euo pipefail

d=$(dirname "${BASH_SOURCE[0]}")

distro=${1:-oracular}

packages=(
    systemd-sysv
    udev
)
packages=$(IFS=, && echo "${packages[*]}")

name="rootfs_rv64_${distro}_initrd_$(date +%Y.%m.%d).tar"

mmdebstrap --include="$packages" \
	   --variant="minbase" \
           --architecture=riscv64 \
	   --components="main restricted multiverse universe" \
	   --customize-hook=$d/systemd-initrd-hvc0-customize-hook.sh \
	   --skip=cleanup/reproducible \
	   --dpkgopt='path-exclude=/usr/share/man/*' \
           --dpkgopt='path-include=/usr/share/man/man[1-9]/*' \
           --dpkgopt='path-exclude=/usr/share/locale/*' \
           --dpkgopt='path-include=/usr/share/locale/locale.alias' \
           --dpkgopt='path-exclude=/usr/share/doc/*' \
           --dpkgopt='path-include=/usr/share/doc/*/copyright' \
           --dpkgopt='path-include=/usr/share/doc/*/changelog.Debian.*' \
           "${distro}" \
           "${name}"

