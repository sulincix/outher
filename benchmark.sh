#!/bin/bash
set -e ; cd /tmp
if readlink $(which date) | grep busybox &>/dev/null ; then
    echo -e "\033[31;1mError: \033[;0mdate command is symlink of busybox"
    exit 1
fi
echo -e "\033[32;1mStarting Benchmark\033[;0m"
rm -f /tmp/file{,.xz,.gz} &>/dev/null
dd if=/dev/urandom of=/tmp/file count=100 bs=1048576 &>/dev/null

declare -r start_time=$(date +%s%N)

echo -e "\033[32;1mStage 1:\033[;0mGenerating random bytes"
dd if=/dev/urandom of=/dev/null count=10485760 bs=1
dd if=/dev/urandom of=/dev/null count=1 bs=10M
echo -e "\033[32;1mStage 2:\033[;0mGenerating zero bytes"
dd if=/dev/zero of=/dev/null count=10485760 bs=1
dd if=/dev/zero of=/dev/null count=1 bs=10M

declare -r byte_time=$(date +%s%N)

echo -e "\033[32;1mStage 3:\033[;0mCompress (100MiB)"
time xz -k /tmp/file
time gzip -k /tmp/file

declare -r compress_time=$(date +%s%N)

echo -e "\033[32;1mStage 4:\033[;0mDecompress (100MiB)"
rm -f /tmp/file ; time xz -d /tmp/file.xz 
rm -f /tmp/file ; time gzip -d /tmp/file.gz

declare -r decompress_time=$(date +%s%N)

echo -e "\033[32;1mStage 5:\033[;0mCalculate hash (100MiB)"
md5sum /tmp/file
sha1sum /tmp/file
sha256sum /tmp/file
sha512sum /tmp/file

declare -r hash_time=$(date +%s%N)

echo -e "\033[32;1mStage 6:\033[;0mSort random data (100MiB)"
time cat /tmp/file | sort &>/dev/null

declare -r sort_time=$(date +%s%N)

echo -e "\033[32;1mStage 7:\033[;0mImage creation"
num=0
while [[ $num -lt  2073600 ]] ; do
    echo "$RANDOM$RANDOM$RANDOM$RANDOM" &>/dev/null
    num=$(($num+1))
done

declare -r image_time=$(date +%s%N)


atime=$((${byte_time}-${start_time}))
btime=$((${compress_time}-${byte_time}))
ctime=$((${decompress_time}-${compress_time}))
dtime=$((${hash_time}-${decompress_time}))
etime=$((${sort_time}-${hash_time}))
ftime=$((${image_time}-${sort_time}))

echo -e "\n\n\033[32;1mResults:"
atime=$(echo "1000000000000/$atime" | bc -l)
btime=$(echo "1000000000000/$btime" | bc -l)
ctime=$(echo "10000000000/$ctime" | bc -l)
dtime=$(echo "100000000000/$dtime" | bc -l)
etime=$(echo "100000000000/$etime" | bc -l)
ftime=$(echo "1000000000000/$ftime" | bc -l)

echo "Byte generation score:" $atime 
echo "Compress score:" $btime 
echo "Decompress score:" $ctime
echo "Hash score:" $dtime
echo "Sort score:" $etime
echo "Image score:" $ftime
echo "Total:" $(echo "$atime + $btime + $ctime + $dtime + $etime + $ftime" | bc -l)
