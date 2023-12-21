# riscv-rootfs-utils

The riscv-rootfs-utils repository contains a set of scripts to build a
Debian derived rootfs for RISC-V.

A 9p host mount is available at /opt/host. Configure in the qemu.sh
script.

It's always uses UEFI and UKI.

This is mostly for my own workflow, so there are some hacks to get it
to work ;-) I'm an Ubuntu/Debian person, and Ukify is, e.g. not available yet.

1. Manually install Ukify

```
mkdir -p ~/src/
cd src
git clone https://github.com/systemd/systemd.git
cd systemd/src/ukify
python -m venv venv
. ./venv/bin/activate
pip install pefile
```

Apply this patch for Ubuntu rootfs:
```
diff --git a/src/ukify/ukify.py b/src/ukify/ukify.py
index 6e9d86b783de..bf93933cc01a 100755
--- a/src/ukify/ukify.py
+++ b/src/ukify/ukify.py
@@ -573,7 +573,7 @@ def pe_add_sections(uki: UKI, output: str):
 
     warnings = pe.get_warnings()
     if warnings:
-        raise PEError(f'pefile warnings treated as errors: {warnings}')
+        pass #raise PEError(f'pefile warnings treated as errors: {warnings}')
 
     security = pe.OPTIONAL_HEADER.DATA_DIRECTORY[pefile.DIRECTORY_ENTRY['IMAGE_DIRECTORY_ENTRY_SECURITY']]
     if security.VirtualAddress != 0:
```

2. Make sure you have qemu-user/mmdebstrap/guestfish working. Note
   that guestfish require your running /boot/vmlinuz to be readable
   for non-root usage.

## Typical usage

Build an Ubuntu image

```
./mkrootfs_rv64_ubuntu.sh
./mkimage rootfs_rv64_mantic_2023.12.21.tar ubuntu.img
```

Boot the image:
```
./qemu.sh ubuntu.img
```

Update kernel to an image:
```
./updimage.sh -k arch/riscv/boot/Image ubuntu.img
```

Update modules to an image:
```
./updimage.sh -m modules/6.7.0-rc4-defconfig_plain-00010-gfe9a5548c514 ubuntu.img
```

My hack/boot flow, after in image is built:

First you need a build wrapper in `~/bin/rvb` (Risc-V Build):
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
~/src/riscv-rootfs-utils/qemu.sh ~/src/riscv-rootfs-utils/ubuntu.img
```

You hack, `rvb`, hack, `rvb`. When it works (or you think it does),
`doit`.

## Misc

If you need a bigger image, change `imsz` in the mkimage script.

If you need more packages installed upfront, change the `packages` in
mkrootfs script.

If you want to customize the rootfs, `hack
systemd-debian-customize-hook.sh`.

If you need a friend, get a dog/cat.

## TODO

Support initramfs => Use Ukify for Debian Sid -- currently the Sid
kernel barfs w/ initramfs
