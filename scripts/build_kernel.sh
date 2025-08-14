#!/bin/bash

set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd $SCRIPT_DIR/../

cd kernel && git checkout -f add-syscall || ( echo "Cannot checkout add-syscall branch"; exit 1 )

if ! (git status | grep -q include/net/tcp.h); then
    set -x
    git apply ../scripts/kernel-polygraph-workaround.patch
fi

if [ "$1" = "qemu" ]; then
    make x86_64_defconfig
    make kvm_guest.config
    make phx.config
    make -j`nproc`
    exit $?
fi

set -x

# To clean all compilation and temporary pathces: make mrproper

cp /boot/config-$(uname -r) .config
make phx.config
scripts/config --disable SYSTEM_REVOCATION_KEYS
scripts/config --disable SYSTEM_TRUSTED_KEYS
scripts/config --disable DEBUG_INFO
yes "" | make -j`nproc`
make bindeb-pkg -j`nproc`

# To install:
# sudo dpkg -i ../*-2_amd64.deb
# To uninstall:
# sudo dpkg -r linux-image-5.15.94+ linux-headers-5.15.94+ linux-libc-dev
