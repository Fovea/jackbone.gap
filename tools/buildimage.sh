#!/bin/bash

function usage() {
    echo "usage: $0 <filename> <w> <h>"
    echo
    echo "Resize image"
    exit 1
}

test -e $PROJECT_PATH || error "This script should't be called directly"

cd $PROJECT_PATH
which convert > /dev/null || error "ImageMagick not installed or not in PATH"

function cropResize() {
    src=$1
    dest=$2
    destfile=$3
    w=$4
    h=$5
    extra=$6
    size="${w}x${h}"
    mkdir -p $dest/img
    convert $src -resize $size\! $dest/img/$destfile

    w2=$((w * 2))
    h2=$((h * 2))
    size="${w2}x${h2}"
    mkdir -p $dest/img-hd
    convert $src -resize $size\! $dest/img-hd/$destfile

    w2=$((w / 2))
    h2=$((h / 2))
    size="${w2}x${h2}"
    mkdir -p $dest/img-ld
    convert $src -resize $size\! $dest/img-ld/$destfile
}

FILE=$1
W=$2
H=$3
if [ x$H = x ]; then
    echo "wrong arguments: $FILE $W $H"
    usage
fi

DEST=build/www

SRC=assets/$FILE
if test -e $SRC; then
    cropResize $SRC $DEST $W $H
else
    SRC=app/img/$FILE
    if test -e $SRC; then
        cropResize $SRC $DEST $FILE $W $H
    else
        echo "none of assets/$FILE and app/img/$FILE exist"
        usage
    fi
fi
