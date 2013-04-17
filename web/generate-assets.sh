#!/bin/bash

which convert > /dev/null || ( echo "ERROR: ImageMagick not installed or not in PATH"; exit 1)

function cropResize() {
    src="$1"
    dest="$2"
    w=$3
    h=$4
    size="${w}x${h}"
    echo -n . # "Resize $src -> $dest $size"
    convert "$src" -resize $size^ -gravity Center -crop $size+0+0 +repage "$dest"
}

DEFAULT="$PROJECT_PATH/assets/Default.png"
SPLASH_PATH="$PROJECT_PATH/build/www/img"

cropResize "$DEFAULT" "$SPLASH_PATH/splash.jpg" 1600 1200
