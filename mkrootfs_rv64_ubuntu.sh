#!/bin/bash
# SPDX-FileCopyrightText: 2023 Rivos Inc.
#
# SPDX-License-Identifier: Apache-2.0

set -euo pipefail

d=$(dirname "${BASH_SOURCE[0]}")

distro=${1:-mantic}

packages=(
    linux-image-generic
    build-essential
)
packages=$(IFS=, && echo "${packages[*]}")

name="rootfs_rv64_${distro}_$(date +%Y.%m.%d).tar"

mmdebstrap --include="$packages" \
           --architecture=riscv64 \
	   --customize-hook=$d/systemd-debian-customize-hook.sh \
	   --skip=cleanup/reproducible \
           "${distro}" \
           "${name}"

