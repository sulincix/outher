#!/bin/bash
echo "kurulu sistem nerede (örneğin /dev/sda3)"
ls /dev/sd*
read disk
echo "MBR girin (örneğin /dev/sda)"
read mbr
if [[ -d /sys/firmware/efi/ ]]
then
  echo "EFI bölümünü girin"
  read efi
  mount $disk /mnt
  mount --bind $efi /mnt/boot/efi
  mount --bind /sys/firmware/efi/efivars /mnt/sys/firmware/efi/efivars
fi
mount --bind /dev /mnt/dev
mount --bind /dev/pts /mnt/dev/pts
mount --bind /sys /mnt/sys
mount --bind /proc /mnt/proc
chroot /mnt grub-install $mbr
chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
