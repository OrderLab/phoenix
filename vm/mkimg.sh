#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd $SCRIPT_DIR

IMG=phx.img
DIR=mountpoint
qemu-img create $IMG 40G
mkfs.ext4 $IMG
mkdir $DIR
sudo mount -o loop $IMG $DIR
sudo debootstrap --arch amd64 bookworm $DIR
sudo cp ../scripts/guest_setup.sh $DIR/tmp/setup.sh
sudo chroot $DIR /tmp/setup.sh
sudo umount $DIR
