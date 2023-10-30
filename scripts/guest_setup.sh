#!/bin/bash

if [[ $(id -u) != 0 ]]; then
	echo Please run this script as root.
	exit 1
fi

apt update
apt install -y xterm neovim git psmisc procps tmux cmake build-essential bison \
	libssl-dev libncurses5-dev pkg-config python3 zlib1g-dev curl cgroup-tools \
	automake autotools-dev libedit-dev libjemalloc-dev libncurses-dev \
	libpcre3-dev libtool libtool-bin python3-docutils python3-sphinx cpio \
	environment-modules tclsh libcurl4-openssl-dev python3-pip python3-pandas


echo '/dev/sda / ext4 errors=remount-ro,acl 0 1' > /etc/fstab
passwd -d root
echo 'resize > /dev/null 2>&1' >> ~/.bashrc
echo 'if [[ $TMUX = "" ]]; then shutdown -h now; fi' > ~/.bash_logout

# Autologin root
sed -i 's/agetty -o/agetty -a root -o/' /usr/lib/systemd/system/serial-getty@.service

# Varnish will set user to "nobody", and then it cannot see its header
# installed in `/root`...  Workaround for this:
chmod 755 /root
