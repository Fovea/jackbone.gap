#!/bin/bash

which convert > /dev/null || error "ImageMagick not installed or not in PATH"

function cropResize() {
    src=$1
    dest=$2
    w=$3
    h=$4
    extra=$5
    size="${w}x${h}"
    echo "Resize $src -> $dest $size    $extra"
    convert $src -resize $size^ -gravity Center -crop $size+0+0 +repage $extra $dest
}

ICON="$PROJECT_PATH/assets/Icon.png"
ICON_PATH="$WWW/res/icon/blackberry"

DEFAULT="$PROJECT_PATH/assets/Default.png"
SPLASH_PATH="$WWW/res/screen/blackberry"

cropResize "$DEFAULT" "$SPLASH_PATH/screen-225.png" 225 225
cropResize "$ICON" "$ICON_PATH/icon-80.png" 80 80
