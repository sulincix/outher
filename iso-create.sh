#!/bin/bash
#Gerekenler: debootstrap grub squashfs-tools okuma-yazma
set -e # eğer hata olursa diğer adımlara geçmeden kapatmak için
#Önce debian chroot çekelim
[ -d ./isowork ] || debootstrap --arch amd64 stable ./isowork
#dizin bağlarını koyalım
mount --bind /dev ./isowork/dev
mount --bind /dev/pts ./isowork/dev/pts
mount --bind /sys ./isowork/sys
mount --bind /proc ./isowork/proc
mount --bind /run ./isowork/run
#Sources.list dosyasını yazalım.
cat > ./isowork/etc/apt/sources.list <<EOF
deb http://deb.debian.org/debian stable main contrib non-free
deb-src http://deb.debian.org/debian stable main contrib non-free
deb http://security.debian.org/debian-security buster/updates main contrib non-free
deb-src http://security.debian.org/ buster/updates main contrib non-free
EOF
chroot ./isowork apt install -y ca-certificates
#Live açılış için gerekenler
chroot ./isowork dpkg --add-architecture i386
chroot ./isowork apt update
chroot ./isowork apt install -y live-boot live-config grub-pc-bin grub-efi lsb-release
#Ek paketler buraya ekleme yapabilirsiniz. Ben aklıma gelenleri ekledim.
chroot ./isowork apt install -y xinit xserver-xorg lightdm xfce4 xfce4-goodies # masaüstü ortamı
chroot ./isowork apt install -y linux-image-amd64 curl network-manager pavucontrol geany vlc gimp \
	inkscape firefox-esr shotwell zsh libreoffice qalculate evince vim ssh kazam htop openshot \
	gnome-boxes filezilla xarchiver rar unrar deluge synaptic build-essential git zenity dialog \
	network-manager-openvpn-gnome ndisgtk network-manager-openvpn network-manager-gnome gparted \
	gigolo font-manager apt-xapian-index gdebi menu gitk banshee chromium-browser fish fontforge \
	kazam plank uget steam nmap pidgin thunderbird timeshift rsync transmission geary evolution \
	clamtk bleachbit autacity ardour blender freecad krita rhythmbox shutter simplescreenrecorder \
	clamav gtk-recordmydesktop smplayer taskwarrior scribus dosbox playonlinux wine32 winetricks \
	kodi arduino adb fastboot octave gksu atril evince net-tools blueman
#Driver paketlerinin tamamı. Burayı kurcalamasanız iyi olur :D
chroot ./isowork apt install \
	firmware-amd-graphics firmware-atheros firmware-b43-installer firmware-b43legacy-installer \
	firmware-bnx2 firmware-bnx2x firmware-brcm80211 firmware-cavium firmware-intel-sound \
	firmware-intelwimax firmware-ipw2x00 firmware-ivtv firmware-iwlwifi firmware-libertas \
	firmware-linux firmware-linux-free firmware-linux-nonfree firmware-misc-nonfree firmware-myricom \
	firmware-netxen firmware-qlogic firmware-realtek firmware-samsung firmware-siano \
	firmware-ti-connectivity firmware-zd1211
#Alttaki satırın açıklamasını kaldırırsanız chroot içerisinde shell açılacaktır. exit yazınca çıkar.
#chroot ./isowork /bin/bash
#Varsayılan root şifresi ayarlayalım.
chroot ./isowork passwd
#Dağıtım isminin değiştirilmesi
cat > ./isowork/etc/os-release << EOF
PRETTY_NAME="Custom Distribution"
NAME="Custom GNU/Linux"
VERSION_ID="1"
VERSION="1 Custom"
VERSION_CODENAME=stable
ID=debian
HOME_URL="https://www.example.org/"
SUPPORT_URL="https://www.example.org/support"
BUG_REPORT_URL="https://bugs.example.org/"
EOF
#desktop-base paketinin yerine boş paket geçirme (debian temalarından kurtulmak için gerekli)
mkdir -p ./isowork/tmp/desktop-base/DEBIAN
cat > ./isowork/tmp/desktop-base/DEBIAN/control << EOF
Package: desktop-base
Priority: optional
Section: x11
Installed-Size: 1
Maintainer: Ali Rıza KESKİN <parduscix@yandex.ru>
Architecture: all
Version: 9999-noupdate
Description: Debian desktop-base killer
EOF
dpkg -b ./isowork/tmp/desktop-base
chroot ./isowork dpkg -i /tmp/desktop-base.deb
#Lmde kurulum aracı için 2 şeye ihtiyacımız var.
#1- deb paketini indirip kurmamız gerekli. Bu aşama tercihe bağlıdır.
wget https://github.com/linuxmint/live-installer/releases/download/2015.09.19/live-installer_2015.09.19_all.deb
mv live-installer_2015.09.19_all.deb ./isowork/tmp/live-installer.deb
chroot dpkg -i ./isowork/tmp/live-installer.deb
#2- paketin bağımlılıkları jessie ve sid depolarında bulunuyor. sid kararsız bu yüzden jessie deposu ekleyeceğiz.
echo "deb https://deb.debian.org/debian jessie main contrib non-free" > ./isowork/etc/apt/sources.list.d/jessie.list
chroot ./isowork apt install -f
#Bağımlılıkları kurdu şimdi jessie deposunu silelim. Lmde installer kurulumu tamamlanmış oldu.
rm -f ./isowork/etc/apt/sources.list.d/jessie.list
#Varsayılan ayarlar /etc/skel içerisinde bulunur. Bu dizindeki dosyalar yeni kullanıcıların ev dizinine atılır. 
#Bu betiğin çalıştırıldığı yerde skel adında bir dizin içindekileri iso taslağına atalım. Dizin yoksa es geçecek.
[ -d ./skel ] && cp -prfv ./skel/* ./isowork/etc/skel/
[ -d ./skel ] && cp -prfv ./skel/.* ./isowork/etc/skel/
#Bağların kesilmesi
umount -lf ./isowork/*
#Temizlik
chroot ./isowork apt clean
rm -rf ./isowork/tmp/*
#Sfs alma işlemi. Biraz uzun sürebilir.
mksquashfs isowork filesystem.squashfs -comp xz -wildcards
#iso taslağı oluşturma
mkdir -p ./iso-template/boot/grub
mkdir -p ./iso-template/live
#taslağın içine gerekli dosyaları taşıma.
mv filesystem.squashfs ./iso-template/live/filesystem.squashfs
cat $(find ./isowork/boot/initrd.img* | sort | head -n 1) > ./iso-template/live/initrd.img
cat $(find ./isowork/boot/vmlinuz* | sort | head -n 1) > ./iso-template/live/vmlinuz
#grub dosyasını yazma.
cat > ./iso-template/boot/grub/grub.cfg << EOF
menuentry "Custom Live Iso" {
	search --file --no-floppy --set=root /live/filesystem.squashfs
	linux /live/vmlinuz boot=live components quiet splash ---
	initrd /live/initrd.img
}

menuentry "Custom Live Iso (Safe Mode)" {
	search --file --no-floppy --set=root /live/filesystem.squashfs
	linux /live/vmlinuz boot=live components memtest noapic noapm nodma nomce nolapic nomodeset nosmp ---
	initrd /live/initrd.img
}
EOF
#iso yapalım.
grub-mkrescue ./iso-template -o custom-live-iso.iso
