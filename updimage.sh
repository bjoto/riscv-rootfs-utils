#!/bin/bash
# SPDX-FileCopyrightText: 2023 Rivos Inc.
#
# SPDX-License-Identifier: Apache-2.0

set -euo pipefail

set -x

d=$(dirname "${BASH_SOURCE[0]}")

kernel=
modpath=

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
              copy-in $kernel /boot/ : \
              copy-in $kernel /boot/efi/ : \
              mv /boot/efi/$(basename $kernel) /boot/efi/Image
fi

if [[ $modpath ]]; then
    guestfish --remote -- copy-in $modpath /lib/modules/
fi

guestfish --remote -- \
          sync : \
          umount /boot/efi : \
          umount / : \
          exit


