#!/bin/bash
#Gerekenler: debootstrap grub squashfs-tools okuma-yazma
set -e # eğer hata olursa diğer adımlara geçmeden kapatmak için
#Önce debian chroot çekelim
[ -d ./isowork ] || debootstrap --arch amd64 --no-merged-usr --exclude=usrmerge testing ./isowork
#dizin bağlarını koyalım
mount --bind /dev ./isowork/dev
mount --bind /dev/pts ./isowork/dev/pts
mount --bind /sys ./isowork/sys
mount --bind /proc ./isowork/proc
mount --bind /run ./isowork/run
#Sources.list dosyasını yazalım.
cat > ./isowork/etc/apt/sources.list <<EOF
deb http://pkgmaster.devuan.org/merged testing main contrib non-free
deb-src http://pkgmaster.devuan.org/merged testing main contrib non-free
EOF
echo "deb http://pkgmaster.devuan.org/merged stable main contrib non-free" > ./isowork/etc/apt/sources.list.d/debian-stable.list
echo "deb http://pkgmaster.devuan.org/merged oldstable main contrib non-free" > ./isowork/etc/apt/sources.list.d/debian-stable.list
#Paket kurulumu yapalım
#Live açılış için gerekenler
chroot ./isowork dpkg --add-architecture i386
chroot ./isowork apt update
chroot ./isowork apt install -y live-boot live-config grub-pc-bin grub-efi  openrc
#Ek paketler buraya ekleme yapabilirsiniz. Ben aklıma gelenleri ekledim.
chroot ./isowork apt install -y xinit xserver-xorg lightdm xfce4 xfce4-goodies # masaüstü ortamı
#Her türlü bloat doldurma girişimi :)
chroot ./isowork apt install -y --no-install-recommends linux-image-amd64 linux-headers-amd64  \
	inkscape firefox-esr shotwell zsh libreoffice evince vim ssh kazam htop openshot network-manager \
	gnome-boxes filezilla xarchiver rar unrar deluge synaptic build-essential git zenity dialog \
	network-manager-openvpn-gnome gnome-disk-utility network-manager-openvpn network-manager-gnome \
	gigolo font-manager apt-xapian-index gdebi menu gitk chromium fish fontforge pavucontrol \
	kazam plank uget steam nmap pidgin thunderbird timeshift rsync transmission geary evolution \
	clamtk bleachbit audacity ardour blender freecad krita rhythmbox simplescreenrecorder gparted \
	clamav smplayer taskwarrior scribus dosbox playonlinux wine32 winetricks geany vlc gimp ark \
	kodi arduino adb fastboot octave atril evince net-tools blueman devscripts squashfs-tools \
	xorriso mtools conky flatpak gnome-builder wireshark p7zip okular kate kwrite gedit aptly  \
	engrampa php apache2 file-roller xfburn cairo-dock busybox-static meson live-build obs-studio \
	catfish tilix neofetch screenfetch tmux screen emacs aria2 gnucash empathy terminator guake \
	lollypop clementine cmus calligra gnome-screenshot curl lsb-release
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
#17g derleyip kuralım
apt-get install git devscripts -y
mkdir 17g-build && cd 17g-build 
git clone https://gitlab.com/ggggggggggggggggg/17g && cd 17g
mk-build-deps --install
debuild -us -uc -b ; cd ../../
cp 17g-build/17g*.deb ./isowork/tmp/17g.deb
chroot ./isowork dpkg -i tmp/17g.deb || true
chroot ./isowork apt-get install -f -y
rm -f ./isowork/tmp/17g.deb 17g-build
chroot ./isowork apt install -f
#Bağımlılıkları kurdu şimdi jessie deposunu silelim. Lmde installer kurulumu tamamlanmış oldu.
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
mksquashfs isowork filesystem.squashfs -comp gzip -wildcards
#iso taslağı oluşturma
mkdir -p ./iso-template/boot/grub
mkdir -p ./iso-template/live
#taslağın içine gerekli dosyaları taşıma.
mv filesystem.squashfs ./iso-template/live/filesystem.squashfs
cat $(find ./isowork/boot/initrd.img* | sort -V | head -n 1) > ./iso-template/live/initrd.img
cat $(find ./isowork/boot/vmlinuz* | sort -V | head -n 1) > ./iso-template/live/vmlinuz
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
