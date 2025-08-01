# QEMU Setup Guide

This document gives a guide to create, start/stop a QEMU VM machine, with kernel developed on the host machine and runtime environment in the guest machine. For evaluation purpose, running on bare metal or other hypervisors is preferred.

**TOC**
- [Host Setup](#hots-setup)
- [Running VM](#running-vm)
- [Guest Setup](#guest-setup)

# Getting Started

## Host Setup

### Toolchain installation

```
sudo apt-get install  debootstrap libguestfs-tools qemu-system-x86

sudo usermod -aG kvm `whoami`
```

### Compile Kernel

```bash
./scripts/build_kernel.sh
```

**Development options**

If debugging kernel with GDB is needed, type `make menuconfig` in the kernel repository, then in "Compile-time checks and compiler options", enable "Compile the kernel with debug info". Enabling this option will result in longer compile time and much larger kernel image.


### Create disk image

```bash
./vm/mkimg.sh
```

If you find downloading slow or stuck, it is possible that the IPv6 configuration on your network is faulty. Fix the network config or disable IPv6.

## Running VM

### Import Shorthands

We also provide a set of shorthands for common operations such as mounting and running on the host:

| Shorthand | Explanation |
| ---- | ---- |
| `m`  | Mount disk image (does not mount if QEMU is running) |
| `um` | Unmount disk image |
| `ch` | `chroot` into mounted disk image (internally requires `sudo`) |
| `r`  | Run the VM (fail if image is still mounted) |
| `k`  | Force kill QEMU |

Import the shorthands into the current shell:
```bash
source vm/shorthands.sh
```

For their implementation, see the [vm/shorthands.sh](vm/shorthands.sh) source code.

## Guest setup

### Network Setup

**Quick option:**

In the VM, run `dhclient`, the VM will have a QEMU software-based NAT, available to download packages, or accessing the host.

### Rescue

If the kernel crashed for some reason, use `CTRL-A` then `x` to force quit the VM. After that, fix the disk image to avoid corrupting the file system before starting the kernel again.

```bash
e2fsck -f phx.img
```

# Reference

- [Linux Kernel Dev Bootcamp](https://github.com/OrderLab/linux-dev-bootcamp/wiki)
