# Phoenix

Phoenix is an OS support that provides optimistic recovery for
high-availability software via partial process state preservation.

The phoenix project consists of:

- A kernel based on Linux 5.15.94 that implements restart with preservation
- A user-level library for phoenix APIs
- A modified glibc and dynamic loader
- A compiler support for unsafe region instrumentation and inject testing

This root repository contains scripts for setting up the host and virtual
machine for running orbit and the experiments.

Table of Contents
======

* [Get Started Guide](#get-started-guide)
   * [Requirements](#requirements)
   * [Environment Setup](#environment-setup)
      * [1. Install toolchain](#1-install-toolchain)
      * [2. Build the Phoenix kernel](#2-build-the-phoenix-kernel)
      * [3. Build Phoenix runtime libraries](#3-build-phoenix-runtime-libraries)
* [Experiments](#experiments)
   * [Experiment Setup](#experiment-setup)
      * [5. Build experiment tools](#5-build-experiment-tools)
      * [6. Build applications](#6-build-applications)
   * [Run Experiments](#run-experiments)

# Get Started Guide

## Requirements

To avoid disturbance with your own environment, we recommend running a **fresh
install** Ubuntu 22.04, either on a bare-metal machine, or on inside a
VM with hardware virtualization support.

* Fresh install Ubuntu 22.04 LTS
* Root privilege
* A x86-64 architecture machine, preferring high core count (e.g. > 30 threads) and high memory availability (e.g. > `2*threads` GB). Smaller machines will still work.
* At least 100GB free disk space, preferring SSD or NVMe drives.

## Environment Setup

### 1. Install toolchain

- **1.1 Clone the repository**

The phoenix project by default will use `~/phoenix` and `~/sysroot` paths. Make
sure no files exist at those two locations.

Make sure you have `git` installed.

```bash
git clone https://github.com/OrderLab/phoenix ~/phoenix
cd ~/phoenix
git submodule update --init --recursive
```

- **1.2 Install dependencies**

Run the following script to install all dependencies. The script will call `sudo`.

```bash
./scripts/env_setup.sh
```

Please be mindful if any error message showed up during the installation.

- **1.3 Setup environment variables**

The previous step installs
[WLLVM](https://github.com/travitch/whole-program-llvm) via pip. Make sure
`$HOME/.local/bin` is in your `PATH`, or set it up with (example in Bash):

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
```

In addition to system libraries, phoenix compiles and installs evaluated
software systems and custom tools in `~/phoenix`.  For easier version
management, we use [Environment Modules](http://modules.sourceforge.net).
Phoenix predefines several module files in `~/phoenix/modulefiles`.

Below shows a setup in Bash. Please modify slightly for your shell of choice.

```bash
echo '[ -z ${MODULESHOME+x} ] && source /usr/share/modules/init/bash' >> ~/.bashrc
echo 'export MODULEPATH="$HOME/phoenix/modulefiles"' >> ~/.bashrc
```

Logout and login again, and check the output of `ml avail`. You will see
predefined module files in `~/phoenix/modulefiles` (but they are not compiled yet).

### 2. Build the Phoenix kernel

- **2.1 Prerequisite**

The compiled kernel is not signed, so make sure Secure Boot is disabled.

Make sure the `/boot/config-$(uname -r)` file is available at that path. The
build script will configure kernel based on it.

A fresh install Ubuntu typically uses `-generic` kernel (you can see the
current running version with `uname -r`), which builds many drivers and might
be slow. If you are running in a VM environment, `linux-image-virtual` or
`linux-image-kvm` may compile less kernel modules and may build faster. To
use such kernel, install it with `apt install`, reboot, and validate that this
kernel works in your environment, and then continue with Phoenix kernel
compiling.

- **2.2 Compile the kernel**

Run the following script to compile the kernel:

```bash
./scripts/build_kernel.sh
```

- **2.3 Installing the kernel**

If compiled successfully, you will see several `.deb` files in the `~/phoenix`
folder, ending in `-X_amd64.deb`, where `X` is the build number. Install the
packages by running (for example if `X` is 1):

```bash
sudo dpkg -i *-1_amd64.deb
```

Restart the machine:

```bash
sudo shutdown -r now
```

Validate that phoenix version is running if the kernel version is `5.15.94+`:

```bash
uname -a
```

### 3. Build Phoenix runtime libraries

- **3.1 Compile glibc, userlib, and compiler**

Compilation of `glibc` may depend on the running kernel, make sure you are
running the Phoenix kernel.

Run the following script to compile them all:

```bash
./scripts/build_runtime.sh
```

- **3.2 Create a sysroot**

To avoid disturbance of other programs on the machine, the below script creates
a standalone sysroot, by cloning the current system sysroot libraries and
overwriting with custom glibc libraries.

Run the following script to generate a sysroot at `~/sysroot`. This folder may
be large (~5GB).

```bash
./scripts/makesysroot.sh
```

# Experiments

## Experiment Setup

### 5. Build experiment tools

Run the following script to automatically download and compile the test frameworks:

```bash
./tools/build_all.sh
```

### 6. Build applications

Run the following script to automatically download and compile all application versions for the experiments:

```bash
./apps/build_all.sh
```

## Run Experiments

Please go to [`experiments`](experiments) directory to see the list of experiments and their usages.
