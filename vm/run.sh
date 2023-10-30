#!/bin/bash

cd $__ORBIT_ROOT_DIR

if [[ $1 = '-d' ]]; then
	DBG='-s -S'  # gdb debug options (port 1234; stop cpu)
	shift
else
	DBG=
fi
# in gdb console, `break start_kernel`

image=kernel/arch/x86/boot/bzImage

KVM=--enable-kvm
#KVM=

qemu-system-x86_64 -kernel $image \
    -hda vm/phx.img \
    -append "root=/dev/sda console=ttyS0 nokaslr" \
    ${DBG} \
    ${KVM} \
    -smp cores=8 -m 16G \
    -nographic
    #-serial stdio -display none

# available for -append: cgroup_enable=memory loglevel=6
