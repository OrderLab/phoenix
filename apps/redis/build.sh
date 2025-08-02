#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd $SCRIPT_DIR 

set -x

git clone https://github.com/OrderLab/phoenix-redis.git code
cd code
make distclean

function fail {
	status=$?
	echo "Compilation Failed!"
	exit $status
}

function build {
	commit=$1
	target=$2
	patch=$3

	git reset --hard && git checkout -f $commit || fail
	[ ! -z "$patch" ] && (git apply $SCRIPT_DIR/$patch || fail)
	make install PREFIX=$SCRIPT_DIR/$target USE_JEMALLOC=no -j$(nproc) || fail
	make distclean || fail
	git checkout -- .
}

build 0ee2046 rel-phx-72 phx-redis.patch || fail
build 4defa86 rel-orig-72 vanilla-redis.patch || fail
build 50e7443 rel-phx-7445 || fail
build 351252a rel-orig-7445 vanilla-redis-7445.patch || fail
