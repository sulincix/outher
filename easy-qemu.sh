#!/bin/bash
export iso=$(zenity --file-selection --text="cdrom image")
export ram=$(zenity --entry --text="RAM")
export img=$(zenity --file-selection --text="disk image")
if [ "$img" == "" ]
then
export img=$(zenity --entry --text="new image name")
export size=$(zenity --entry --text="size")
qemu-img create "$img" "$size"
fi
export core=$(zenity --entry --text="core")
kvm -cdrom "$iso" -hda "$img" -m "$ram" -cpu host -smp cores="$core" --usbdevice mouse --usbdevice keyboard -boot d -soundhw ac97 -vga vmware
