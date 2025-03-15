#!/bin/bash

set -euo pipefail
set -x

d=$(dirname "${BASH_SOURCE[0]}")

rootfs=$(readlink -f $1)
tmp=$(mktemp -d)

fakeroot tar -C $tmp --extract --xattrs --xattrs-include='*' -f $rootfs
out=$(readlink -f $PWD)/output.cpio
cd $tmp
fakeroot bash -c "find . -print0 | cpio -o --null --format=newc > $out"
rm -rf $tmp
