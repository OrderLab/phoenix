#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd $SCRIPT_DIR

set -e

mkdir -p ycsb-bin

cd ycsb/

git checkout -- .
git apply ../ycsb-customize.patch

mvn -pl site.ycsb:redis-binding -am clean package
tar -xf redis/target/ycsb-redis-binding-*.tar.gz \
	-C $SCRIPT_DIR/ycsb-bin/ --strip-components=1
