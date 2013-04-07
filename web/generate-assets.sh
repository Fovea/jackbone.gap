#!/bin/bash

which convert || ( echo "ERROR: ImageMagick not installed or not in PATH"; exit 1)

function cropResize() {
    src=$1
    dest=$2
    w=$3
    h=$4
    size="${w}x${h}"
    echo "Resize $src -> $dest $size"
    convert $src -resize $size^ -gravity Center -crop $size+0+0 +repage $dest
}

SPLASH_PATH=build/www/img
DEFAULT=assets/Default.png 

cropResize $DEFAULT $SPLASH_PATH/splash.jpg 1600 1200
