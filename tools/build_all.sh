#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd $SCRIPT_DIR

failed=()
for name in ycsb criu polygraph; do
    if ! ./install_$name.sh; then
        failed+=(tools/install_$name.sh)
    fi
done
if [ ${#failed[@]} -ne 0 ]; then
    echo "Failed build scripts:" ${failed[@]}
    exit 1
fi
