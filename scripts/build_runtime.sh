#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

set -x

cd $SCRIPT_DIR/../

cd glibc/ && \
git checkout 011bc731 && \
mkdir -p build && cd build && \
../configure --prefix=$HOME/sysroot && \
make -j$(nproc) || ( echo "Compile glibc failed!"; exit 1 )

cd $SCRIPT_DIR/../

cd ~/phoenix/userlib/ && \
git checkout add-systemcall && \
mkdir -p build && cd build && \
cmake ../ -DCMAKE_BUILD_TYPE=Release && \
make -j$(nproc) || ( echo "Compile userlib failed!"; exit 1 )

cd $SCRIPT_DIR/../

cd compiler/ && \
mkdir -p build && cd build && \
CC=clang-15 CXX=clang++-15 cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_EXPORT_COMPILE_COMMANDS=ON && \
make -j$(nproc) && \
cd ../test/ && make runtime || ( echo "Compile compiler failed!"; exit 1 )
