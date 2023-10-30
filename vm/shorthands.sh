export __PHX_ROOT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )/../" &> /dev/null && pwd )
export __PHX_IMAGE_FILE=$__PHX_ROOT_DIR/vm/phx.img
export __PHX_MOUNT_DIR=$__PHX_ROOT_DIR/vm/mountpoint
function mount_qemu_image() {
    sudo mount -o loop $__PHX_IMAGE_FILE $__PHX_MOUNT_DIR && \
    sudo mount -o bind,ro /dev $__PHX_MOUNT_DIR/dev && \
    sudo mount -o bind,ro /dev/pts $__PHX_MOUNT_DIR/dev/pts && \
    sudo mount -t proc none $__PHX_MOUNT_DIR/proc
}
function unmount_qemu_image() {
    busy_process=$(sudo lsof $__PHX_MOUNT_DIR | awk '{print($2)}')
    if [ ! -z "$busy_process" ]; then
        echo "Mount point $__PHX_MOUNT_DIR is busy."
        echo "Used by the following processes:"
        sudo lsof $__PHX_MOUNT_DIR
        echo "To unmount it, exit these processes"
        echo "(e.g., 'cd ..' if your shell is inside the mount point)."
        return 1
    fi

    sudo umount $__PHX_MOUNT_DIR/dev/pts
    sudo umount $__PHX_MOUNT_DIR/dev
    sudo umount $__PHX_MOUNT_DIR/proc
    sudo umount $__PHX_MOUNT_DIR
}
# Mount/unmount disk image (do not mount if qemu is running)
alias m='pgrep qemu && echo "QEMU is running (with pid above)" || mount_qemu_image'
alias um=unmount_qemu_image
# Chroot into mounted disk image
# (`sudo' is used for setting $HOME and other variables correctly)
alias ch='sudo -i chroot $__PHX_MOUNT_DIR'
# Run the VM (fail if still mounted)
alias r='um; (mount | grep $__PHX_MOUNT_DIR) || $__PHX_ROOT_DIR/vm/run.sh'
# Force kill QEMU
alias k='killall qemu-system-x86_64'
