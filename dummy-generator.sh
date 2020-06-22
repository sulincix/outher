#!/bin/bash
[ "$CC" == "" ] && CC=gcc
objdump -TC $1 | grep ".text" | awk '{print $7}' | \
    sed "s/^/void /g" | sed "s/$/(){}/g" > $(basename $1 | sed "s/.so$/.c/g")
$CC $CFLAGS -o $(basename $1) $(basename $1 | sed "s/.so$/.c/g") -shared