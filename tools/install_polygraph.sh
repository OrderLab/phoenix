#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd $SCRIPT_DIR

set -e

wget -O polygraph-4.13.0-src.tgz https://www.web-polygraph.org/downloads/srcs/polygraph-4.13.0-src.tgz
tar xf polygraph-4.13.0-src.tgz
cd polygraph-4.13.0
./configure --prefix=$SCRIPT_DIR/polygraph-bin
make -j$(nproc) && make install
