#!/bin/bash
set -ex
#install dependencies
apt install grub-pc-bin grub-efi squashfs-tools xorriso mtools -y

#overlayfs mount
mkdir -p /tmp/work/source /tmp/work/a /tmp/work/b /tmp/work/target /tmp/work/empty \
         /tmp/work/iso/live/ /tmp/work/iso/boot/grub/|| true
touch /tmp/work/empty-file
umount -v -lf -R /tmp/work/* || true
mount --bind / /tmp/work/source
mount -t overlay -o lowerdir=/tmp/work/source,upperdir=/tmp/work/a,workdir=/tmp/work/b overlay /tmp/work/target

#resolv.conf fix
export rootfs=/tmp/work/target
rm -f $rootfs/etc/resolv.conf || true
echo "nameserver 1.1.1.1" > $rootfs/etc/resolv.conf

#live-boot install
chroot $rootfs apt install live-config live-boot -y
chroot $rootfs apt autoremove -y
chroot $rootfs apt clean -y
echo -e "live\nlive\n" | chroot $rootfs passwd

#mount empty file and directories
for i in dev sys proc run tmp root media mnt; do
    mount -v --bind /tmp/work/empty $rootfs/$i
done

#hide flatpak applications (optional)
[[ -d $rootfs/var/lib/flatpak ]] && mount -v --bind /tmp/work/empty $rootfs/var/lib/flatpak

#remove users
for u in $(ls /home/) ; do
    chroot $rootfs userdel -fr $u
done

mount --bind /tmp/work/empty-file $rootfs/etc/fstab

#clear rootfs
find -type f $rootfs/var/log | xargs rm -f

#create squashfs
if [[ ! -f /tmp/work/iso/live/filesystem.squashfs ]] ; then
    mksquashfs $rootfs /tmp/work/iso/live/filesystem.squashfs -comp gzip -wildcards
fi

#umount all
umount -v -lf -R /tmp/work/* || true

#write grub file
grub=/tmp/work/iso/boot/grub/grub.cfg
echo "insmod all_video" > $grub
dist=$(cat /etc/os-release | grep ^PRETTY_NAME | cut -f 2 -d '=' | head -n 1 | sed 's/\"//g')
for k in $(ls /boot/vmlinuz-*) ; do
    ver=$(echo $k | sed "s/.*vmlinuz-//g")
    if [[ -f /boot/initrd.img-$ver ]] ; then
        cp -f $rootfs/boot/vmlinuz-$ver /tmp/work/iso/boot
        cp -f $rootfs/boot/initrd.img-$ver /tmp/work/iso/boot
        echo "menuentry \"$dist ($ver)\" {" >> $grub
        echo "    linux /boot/vmlinuz-$ver boot=live live-config quiet splash" >> $grub
        echo "    initrd /boot/initrd.img-$ver" >> $grub
        echo "}" >> $grub
    fi
done

# create iso
grub-mkrescue /tmp/work/iso/ -o ./live-image-$(date +%s).iso


