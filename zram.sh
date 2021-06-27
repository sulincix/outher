#!/bin/bash
cpu=$(nproc)
modprobe zram num_devices=$cpu
total=$(LANG=C free | grep -e "^Mem" | xargs bash -c 'echo $1')
mem=$(($total*1024))
for ((i=0;i<$cpu;i++)) ; do
    echo $mem > /sys/block/zram$i/disksize
    mkswap /dev/zram$i
    swapon -p 5 /dev/zram$i
done
