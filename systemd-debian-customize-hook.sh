#!/bin/bash
# SPDX-FileCopyrightText: 2023 Rivos Inc.
#
# SPDX-License-Identifier: Apache-2.0

echo rivos > "$1/etc/hostname"
echo 44f789c720e545ab8fb376b1526ba6ca > "$1/etc/machine-id"
echo 'host0 /opt/host 9p trans=virtio,version=9p2000.L 0 0' > "$1/etc/fstab"

mkdir -p "$1/etc/systemd/system/serial-getty@ttyS0.service.d"
cat > "$1/etc/systemd/system/serial-getty@ttyS0.service.d/autologin.conf" << "EOF"
[Service]
ExecStart=
ExecStart=-/sbin/agetty -o '-p -f -- \u' --keep-baud --autologin root 115200,57600,38400,9600 - $TERM
EOF
