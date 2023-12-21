# riscv-rootfs-utils

The riscv-rootfs-utils repository contains a set of scripts to build a
Debian derived rootfs for RISC-V.

A 9p host mount is available at /opt/host. Configure in the qemu.sh
script.

It always uses UEFI and UKI.

## Typical usage

Build an Ubuntu image and boot it:

```
./mkrootfs_rv64_ubuntu.sh
./mkimage rootfs_rv64_mantic_2023.12.21.tar ubuntu.img
./qemu.sh ubuntu.img
````

Update kernel to an image:
```
./updimage.sh -k arch/riscv/boot/Image ubuntu.img
```

Update modules to an image:
```
./updimage.sh -m modules/6.7.0-rc4-defconfig_plain-00010-gfe9a5548c514 ubuntu.img
```

Linux hacking flow, after in image is built:
rvb executable:
```
make ARCH=riscv CROSS_COMPILE="ccache riscv64-linux-gnu-" PAHOLE=~/src/pahole/build/pahole -j $(($(nproc)-1)) $*
```

doit
```
#!/bin/bash

set -euo pipefail

d=$(dirname "${BASH_SOURCE[0]}")

tmp=$(mktemp -d)

cleanup() {
    rm -rf "$tmp"
}
trap cleanup EXIT

~/bin/rvb INSTALL_MOD_STRIP=1 INSTALL_MOD_PATH=$tmp modules_install
~/src/riscv-rootfs-utils/updimage.sh -m $tmp/lib/modules -k arch/riscv/boot/Image ~/src/riscv-rootfs-utils/ubuntu.img
~/src/riscv-rootfs-utils/qemu.sh ~/src/riscv-rootfs-utils/ubuntu.img
```

## TODO

Support initramfs => Use Ukify for Debian Sid
