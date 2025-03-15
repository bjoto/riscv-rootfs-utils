#!/bin/bash

set -euo pipefail
set -x

d=$(dirname "${BASH_SOURCE[0]}")

kernel=$1
dtb=$2
# cpio $3

ukify build --efi-arch=riscv64 \
      --stub=/usr/lib/systemd/boot/efi/linuxriscv64.efi.stub \
      --linux=$kernel \
      --devicetree=$dtb \
      --cmdline="fdt_verbose debug earlycon=sbi console=hvc0 loglevel=8" \
      --uname="bt" \
      --initrd=output.cpio \
      -o output.efi
