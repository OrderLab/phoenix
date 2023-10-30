#!/bin/bash
set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd $SCRIPT_DIR/../

git submodule update --init --remote kernel

cd kernel
make x86_64_defconfig
make kvm_guest.config
make phx.config

make -j`nproc`
