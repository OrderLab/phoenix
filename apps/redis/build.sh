#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd $SCRIPT_DIR 

git clone git@github.com:OrderLab/phoenix-redis.git code
cd code
make distclean

function build {
	commit=$1
	target=$2
	patch=$3

	git reset --hard && git checkout -f $commit || exit 1
	[ ! -z "$patch" ] && git apply $SCRIPT_DIR/$patch || exit 1
	make USE_JEMALLOC=no -j$(nproc) || exit 1
	make install PREFIX=$SCRIPT_DIR/$target || exit 1
	make distclean || exit 1
	git checkout -- .
}

build ff28130 rel-phx-72 phx-redis.patch || exit $?
build 4defa86 rel-orig-72 vanilla-redis.patch || exit $?
build cc3e659 rel-phx-7445 || exit $?
build 351252a rel-orig-7445 vanilla-redis-7445.patch || exit $?
