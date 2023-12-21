# riscv-rootfs-utils

The riscv-rootfs-utils repository contains a set of scripts to build a
Debian derived rootfs for RISC-V.

A 9p host mount is available at /opt/host. Configure in the qemu.sh
script.

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

(Or do it both at the same time...)

## TODO

Support initramfs => Use Ukify for Debian Sid
