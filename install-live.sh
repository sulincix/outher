#!/bin/bash
export DISK=sda
export username=user
export password=pass
echo "If you press any key in 3 seconds, switch to edit mode"
echo "Waiting 3 seconds..."
if timeout 3 sh -c "read -n 1" ; then
    echo "Please input target disk: (example sda)"
    read DISK
    echo "Please input username: (example user)"
    read username
    echo "Please input password: (example abc123)"
    read password
fi
mount -t devtmpfs devtmpfs /dev || true
mount -t proc proc /proc || true
mount -t sysfs sysfs /sys || true
mkdir /source /target || true
mount /dev/loop0 /source || true
fallback(){
        /bin/bash
        if [[ $$ -eq 0 ]] ; then
            echo o > /proc/sysrq-trigger
        else
            exit 1
        fi
}
# TODO: Look here again :)
dd if=/dev/zero of=/dev/${DISK} bs=512 count=1
if [[ -d /sys/firmware/efi ]] ; then
    yes | parted /dev/${DISK} mktable gpt || fallback
    yes | parted /dev/${DISK} mkpart primary fat32 1 "100MB" || fallback
    yes | parted /dev/${DISK} mkpart primary fat32 100MB "100%" || fallback
    yes | mkfs.vfat /dev/${DISK}1 || fallback
    yes | parted /dev/${DISK} set 1 esp on || fallback
    yes | mkfs.ext4  /dev/${DISK}2 || fallback
    mount /dev/${DISK}2  /target || fallback
else
    yes | parted /dev/${DISK} mktable msdos || fallback
    yes | parted /dev/${DISK} mkpart primary fat32 1 "100%" || fallback
    yes | mkfs.ext4 /dev/${DISK}1  || fallback
    yes | parted /dev/${DISK} set 1 boot on || fallback
    mount /dev/${DISK}1 /target  || fallback
fi
#rsync -avhHAX /source/ /target
ls /source/ | xargs -n1 -P$(nproc) -I% rsync -avhHAX /source/% /target/  || fallback
if [[ -d /sys/firmware/efi ]] ; then
    echo "/dev/${DISK}2 /               ext4    errors=remount-ro        0       1" > /target/etc/fstab  || fallback
    echo "/dev/${DISK}1 /boot/efi       vfat    umask=0077               0       1" >> /target/etc/fstab  || fallback
else
    echo "/dev/${DISK}1 /               ext4    errors=remount-ro        0       1" > /target/etc/fstab  || fallback
fi
if [[ -d /sys/firmware/efi ]] ; then
    mkdir -p /target/boot/efi || true
    mount /dev/${DISK}1 /target/boot/efi  || fallback
fi
for i in dev sys proc run 
do
    mkdir -p /target/$i || true 
    mount --bind /$i /target/$i  || fallback
done
if [[ -d /sys/firmware/efi ]] ; then
    mount --bind /sys/firmware/efi/efivars /target/sys/firmware/efi/efivars || fallback
fi
chroot /target apt-get purge live-boot* live-config* live-tools --yes || true
chroot /target apt-get autoremove --yes || true
chroot /target update-initramfs -u -k all  || fallback
chroot /target useradd -m $username
mkdir /target/home/$username || true
chroot /target chown $username /home/$username
echo -e "$password\n$password\n" | chroot /target passwd $username
#echo -e "$password\n$password\n" | chroot /target passwd root
for grp in cdrom floppy sudo audio dip video plugdev netdev bluetooth lpadmin scanner ; do
    chroot /target usermod -aG $grp $username
done
if [[ -d /sys/firmware/efi ]] ; then
    chroot /target grub-install /dev/${DISK} --target=x86_64-efi || fallback
else
    chroot /target grub-install /dev/${DISK} --target=i386-pc || fallback
fi
echo "GRUB_DISABLE_OS_PROBER=true" >> /target/etc/default/grub
chroot /target update-grub  || fallback
[[ -f /target/install ]] && rm -f /target/install
umount -f -R /target/* || true
sync  || fallback
echo "Installation done. System restarting in 10 seconds. Press any key to restart immediately."
timeout 10 read -n 1
echo b > /proc/sysrq-trigger
