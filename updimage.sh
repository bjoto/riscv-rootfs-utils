#!/bin/bash
# SPDX-FileCopyrightText: 2023 Rivos Inc.
#
# SPDX-License-Identifier: Apache-2.0

set -euo pipefail

d=$(dirname "${BASH_SOURCE[0]}")

tmp=$(mktemp -d)

cleanup() {
    rm -rf "$tmp"
}
trap cleanup EXIT

kernel=
modpath=
cmdline='root=/dev/vda2 rw earlycon console=tty0 console=ttyS0'

while getopts k:m:n name ; do
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

imagename=$1

imsz=1
if [[ $modpath ]]; then
    imsz=$(du -B 1G -s "$modpath" | awk '{print $1}')
fi

eval "$(guestfish --listen)"

guestfish --remote -- \
          add "$imagename" : \
          launch : \
          mount /dev/sda2 / : \
          mount /dev/sda1 /boot/efi

if [[ $kernel ]]; then
    guestfish --remote -- \
              copy-out /usr/lib/systemd/boot/efi/linuxriscv64.efi.stub $tmp/

    $d/ukify.sh $tmp/linuxriscv64.efi.stub $kernel "$cmdline" $tmp/Image

    guestfish --remote -- \
              rm /boot/efi/Image : \
              copy-in $tmp/Image /boot/efi/
fi

if [[ $modpath ]]; then
    guestfish --remote -- copy-in $modpath /lib/
fi

guestfish --remote -- \
          sync : \
          umount /boot/efi : \
          umount / : \
          exit


