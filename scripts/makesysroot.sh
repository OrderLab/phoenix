#!/bin/bash

set -x
set -e

mkdir -p ~/sysroot/lib/
rsync -rlptD /lib/ ~/sysroot/lib/
# i.e. -a without group and owner

cd ~/phoenix/glibc/build/ && make install

# installcmd=cp
installcmd='ln -sf'

$installcmd ~/phoenix/userlib/build/lib/libphx.so ~/sysroot/lib/
$installcmd ~/phoenix/userlib/lib/include/phx.h ~/sysroot/include/

$installcmd ~/phoenix/compiler/include/phx_instrument.h ~/sysroot/include/
$installcmd ~/phoenix/compiler/test/phxruntime.o ~/sysroot/lib/phxruntime.o
