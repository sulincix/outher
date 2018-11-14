#!/bin/bash
export res="https://gitlab.com/parduscix/iso_duzenleyici/raw/master/iso_olusturucu/binary"
export pwd=$(pwd)
if [ "$1" != "nochroot" ]
then
  rm -rvf ./chroot 2> /dev/null
  mkdir -p ./chroot 2> /dev/null
  `ls / | grep -v home | grep -v dev | grep -v root | grep -v sys | grep -v media | grep -v mnt | | grep -v proc | sed "s|^|cp -prvf /|" | sed "s|$| ./chroot/|"`
  rmdir ./chroot/* 2> /dev/null
  mkdir -p ./chroot/{dev,sys,proc,home,root,media,mnt} 2> /dev/null
  chroot ./chroot "deluser $(ls /home/)"
  echo > ./chroot/etc/fstab
  mksquashfs ./chroot ./filesystem.squashfs -comp xz -wildcards
fi
if [ -d $pwd/binary ]
then
  echo "Skipping to create binary directory"
else
  mkdir -p $pwd/binary/{boot,grub,isolinux,live}
  mkdir -p $pwd/binary/boot/grub/
  mkdir -p $pwd/binary/efi/boot/
  cd $pwd/binary/boot/grub/
  wget -c $res/boot/grub/efi.img 
  wget -c $res/boot/grub/grub.cfg 
  cd $pwd/binary/efi/boot
  wget -c $res/efi/boot/BOOTx64.EFI 
  wget -c $res/efi/boot/bootia32.efi 
  wget -c $res/efi/boot/bootia32.EFI 
  wget -c $res/efi/boot/grubx64.EFI 
  wget -c $res/efi/boot/grubx64.efi 
  cd $pwd/binary/isolinux
  wget -c $res/isolinux/boot.cat 
  wget -c $res/isolinux/hdt.c32 
  wget -c $res/isolinux/isohybrid-mbr 
  wget -c $res/isolinux/isolinux.bin 
  wget -c $res/isolinux/isolinux.cat 
  wget -c $res/isolinux/isolinux.cfg 
  wget -c $res/isolinux/ldlinux.c32 
  wget -c $res/isolinux/libcom32.c32 
  wget -c $res/isolinux/libutil.c32 
  wget -c $res/isolinux/live.cfg 
  wget -c $res/isolinux/menu.cfg 
  wget -c $res/isolinux/splash.png 
  wget -c $res/isolinux/stdmenu.cfg 
  wget -c $res/isolinux/vesamenu.c32 
fi
cd $pwd
rm -rf $pwd/binary/live/filesystem.squashfs 2> /dev/null
mv filesystem.squashfs $pwd/binary/live/filesystem.squashfs
dd if=/initrd.img of=$pwd/binary/live/initrd.img
dd if=/vmlinuz of=$pwd/binary/live/vmlinuz
export binary=$pwd/binary
cd $pwd
xorriso -as mkisofs \
        -iso-level 3 -rock -joliet \
        -max-iso9660-filenames -omit-period \
        -omit-version-number -relaxed-filenames -allow-lowercase \
        -volid "CustomLiveIso" \
        -eltorito-boot isolinux/isolinux.bin \
        -eltorito-catalog isolinux/isolinux.cat \
        -no-emul-boot -boot-load-size 4 -boot-info-table \
        -eltorito-alt-boot -e boot/grub/efi.img -isohybrid-gpt-basdat -no-emul-boot \
        -isohybrid-mbr $binary/isolinux/isohybrid-mbr \
-output "live-image-amd64.hybrid.iso" $binary
