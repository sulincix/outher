#!/bin/bash
export link=$(curl "https://search.apps.ubuntu.com/api/v1/search?q=$1" | sed "s|\.snap\".*|.snap|g" | grep "https://" | sed "s|.*\"https://|https://|g" 2> /dev/null)
echo "$link"
wget -c "$link" -O "$1.snap"

mount "$1.snap" /mnt
mkdir -p /snap/bin 2> /dev/null
mkdir -p /snap/$1
cp -prvf /mnt/* /snap/$1/
echo "export SNAP=/snap/$1/" > /snap/bin/$1
echo "export SNAP_USER_DATA=\$HOME/.snap">> /snap/bin/$1
echo "export SNAP_ARCH=amd64">> /snap/bin/$1
echo "export SNAP_USER_COMMON=\$HOME/.snap">> /snap/bin/$1
echo "export HOME=\$HOME/.snap">> /snap/bin/$1
echo "export PATH=$PATH:$1/bin:$1/usr/bin">> /snap/bin/$1
echo "LD_LIBRARY_PATH=/snap/$1/usr/lib/x86_64-linux-gnu:/snap/$1/lib/x86_64-linux-gnu $1 \$*" >> /snap/bin/$1
chmod 755 /snap/bin/$1
umount /mnt