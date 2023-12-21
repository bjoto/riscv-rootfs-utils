#!/bin/bash
# SPDX-FileCopyrightText: 2023 Rivos Inc.
#
# SPDX-License-Identifier: Apache-2.0

set -euo pipefail

d=$(dirname "${BASH_SOURCE[0]}")

rootfs=$1
imagename=$2

tmp=$(mktemp -d)

cleanup() {
    rm -rf "$tmp"
}
trap cleanup EXIT

kernel=
modpath=
cmdline='root=/dev/vda2 rw earlycon console=tty0 console=ttyS0'

while getopts k:m: name ; do
    case $name in
        k)
            kernel="$OPTARG"
            ;;
        m)
            modpath="$OPTARG"
            ;;
        ?)
            exit 1
            ;;
    esac
done
shift $(($OPTIND -1))

if [[ ! $kernel ]]; then
    tar --extract --file=$rootfs -C $tmp --wildcards './boot/vmlinu?-*' --strip-components=2
    kernel=$(echo $tmp/vmlinu?*)
fi

tar --extract --file=$rootfs -C $tmp ./usr/lib/systemd/boot/efi/linuxriscv64.efi.stub
$d/ukify.sh $tmp/usr/lib/systemd/boot/efi/linuxriscv64.efi.stub $kernel "$cmdline" $tmp/Image.efi
kernel=$tmp/Image.efi

rm -rf $imagename

imsz=1
if [[ -n $modpath ]]; then
    imsz=$(du -B 1G -s "$modpath" | awk '{print $1}')
fi

imsz=$(( ${imsz} + 4 ))

eval "$(guestfish --listen)"

guestfish --remote -- \
          disk-create "$imagename" raw ${imsz}G : \
          add-drive "$imagename" format:raw : \
          launch : \
          part-init /dev/sda gpt : \
          part-add /dev/sda primary 2048 526336 : \
          part-add /dev/sda primary 526337 -34 : \
          part-set-gpt-type /dev/sda 1 C12A7328-F81F-11D2-BA4B-00A0C93EC93B : \
          mkfs ext4 /dev/sda2 : \
          mount /dev/sda2 / : \
          mkdir /boot : \
          mkdir /boot/efi : \
          mkfs vfat /dev/sda1 : \
          mount /dev/sda1 /boot/efi : \
          tar-in $rootfs / : \
          copy-in $kernel /boot/efi/ : \
          mv /boot/efi/$(basename $kernel) /boot/efi/Image


if [[ $modpath ]]; then
    guestfish --remote -- copy-in $modpath /lib/modules/
fi

guestfish --remote -- \
          sync : \
          umount /boot/efi : \
          umount / : \
          exit
