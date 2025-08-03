#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd $SCRIPT_DIR

set -e

wget -O criu-3.17.1.tgz https://github.com/checkpoint-restore/criu/archive/refs/tags/v3.17.1.tar.gz
tar xf criu-3.17.1.tgz
cd criu-3.17.1
make -j$(nproc) install PREFIX=$SCRIPT_DIR/criu-bin
