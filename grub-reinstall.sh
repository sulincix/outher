#!/bin/bash
echo "kurulu sistem nerede (örneğin /dev/sda3)"
ls /dev/sd*
read disk
echo "MBR girin (örneğin /dev/sda)"
read mbr
echo "EFI bölümünü girin (legacy kullanıyorsanız 0 yazın)"
read efi
mount $disk /mnt
if [ "$efi" != "0" ]
then
  mount --bind $efi /mnt/boot/efi
fi
mount --bind /dev /mnt/dev
mount --bind /dev/pts /mnt/dev/pts
mount --bind /sys /mnt/sys
mount --bind /proc /mnt/proc
chroot /mnt grub-install $mbr
chroot /mnt update-grub
