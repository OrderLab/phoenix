#!/bin/bash

sudo apt update

misc=(xterm neovim git psmisc procps tmux)
kernelbuild=(libncurses-dev gawk flex bison openssl libssl-dev dkms libelf-dev libudev-dev libpci-dev libiberty-dev autoconf dwarves)
llvm=(libstdc++-12-dev \
	llvm-15 llvm-15-dev llvm-15-linker-tools llvm-15-runtime llvm-15-tools \
	clang-15 libclang-15-dev python3-clang-15 libc++-15-dev)
build=(cmake build-essential \
	libssl-dev libncurses5-dev pkg-config python3 zlib1g-dev curl cgroup-tools \
	automake autotools-dev libedit-dev libjemalloc-dev libncurses-dev \
	libpcre3-dev libtool libtool-bin python3-docutils python3-sphinx cpio \
	environment-modules tclsh libcurl4-openssl-dev python3-pip python3-pandas \
	libgmp-dev libmpfr-dev texinfo maven)
#binutil
# --allow-change-held-packages is kinda dangerous.. but idk why dkms is holding it back
sudo apt install -y --allow-change-held-packages ${misc[@]} ${kernelbuild[@]} ${llvm[@]} ${build[@]}

# Should work with ASLR as well but just to be smooth..
if ! grep -q "^kernel.randomize_va_space" /etc/sysctl.conf; then
    echo "kernel.randomize_va_space = 0" | sudo tee -a /etc/sysctl.conf
fi
sudo sysctl -p

pip install wllvm

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain nightly --profile complete

if [ "$1" != "qemu" ]; then
    exit $status
fi
# Below are destructive, and only for qemu guest machine setup

echo '/dev/sda / ext4 errors=remount-ro,acl 0 1' > /etc/fstab
passwd -d root
echo 'resize > /dev/null 2>&1' >> ~/.bashrc
echo 'if [[ $TMUX = "" ]]; then shutdown -h now; fi' > ~/.bash_logout

# Autologin root
sed -i 's/agetty -o/agetty -a root -o/' /usr/lib/systemd/system/serial-getty@.service

# Varnish will set user to "nobody", and then it cannot see its header
# installed in `/root`...  Workaround for this:
chmod 755 /root
