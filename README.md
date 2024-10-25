# riscv-rootfs-utils

The riscv-rootfs-utils repository contains a set of scripts to build
firmware, qemu, and rootfs for RISC-V.

A 9p host mount is available at /opt/host. Configure in the qemu.sh
script.

It's always uses UEFI, and defaults to RVA23.

Make sure you have qemu-user/mmdebstrap/guestfish working. Note that
guestfish require your running /boot/vmlinuz to be readable for
non-root usage.

## Typical usage

Bootstrap firmware, qemu, and a raw image
```
./prepare.sh
```

Boot the image:
```
./qemu.sh dt noble.img /hostpath/that/shows/up/in/opt/host
./qemu.sh acpi noble.img /hostpath/that/shows/up/in/opt/host
```

Update kernel to an image:
```
./updimage.sh -k arch/riscv/boot/Image noble.img
```

Update modules to an image:
```
./updimage.sh -m modules/6.7.0-rc4-defconfig_plain-00010-gfe9a5548c514 ubuntu.img
```

My hack/boot flow, after `prepare.sh` has been run:

First you need a build wrapper in `~/bin/rvb` (RISC-V Build):
```
make ARCH=riscv CROSS_COMPILE="ccache riscv64-linux-gnu-" PAHOLE=~/src/pahole/build/pahole -j $(($(nproc)-1)) $*
```

Then you need a `~/bin/doit` (as in Zoolander DO IT):

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
~/src/riscv-rootfs-utils/qemu.sh acpi ~/src/riscv-rootfs-utils/ubuntu.img /home/bjorn/src
```

You hack, `rvb`, hack, `rvb`. When it works (or you think it does),
`doit`.

The kernel command line can be changed in the `qemu.sh` script.

## Misc

If you need a bigger image, change `imsz` in the mkimage script.

If you need more packages installed upfront, change the `packages` in
mkrootfs script.

If you want to customize the rootfs, `hack
systemd-debian-customize-hook.sh`.

If you need a friend, get a dog/cat.
