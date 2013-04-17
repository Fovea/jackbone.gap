#!/bin/bash

which convert > /dev/null || error "ImageMagick not installed or not in PATH"

function cropResize() {
    src="$1"
    dest="$2"
    w=$3
    h=$4
    extra=$5
    size="${w}x${h}"
    echo -n . # "Resize $src -> $dest $size    $extra"
    convert "$src" -resize $size^ -gravity Center -crop $size+0+0 +repage $extra "$dest"
}

ICON_PATH="$IOS_PROJECT_PATH/$PROJECT_NAME/Resources/icons"
SPLASH_PATH="$IOS_PROJECT_PATH/$PROJECT_NAME/Resources/splash"

DEFAULT="$PROJECT_PATH/assets/Default.png"
ICON="$PROJECT_PATH/assets/Icon.png"

cropResize "$DEFAULT" "$SPLASH_PATH/Default-568h@2x~iphone.png" 639 1136
cropResize "$DEFAULT" "$SPLASH_PATH/Default-Landscape@2x~ipad.png" 2048 1536
cropResize "$DEFAULT" "$SPLASH_PATH/Default-Landscape~ipad.png" 1024 768
cropResize "$DEFAULT" "$SPLASH_PATH/Default-Portrait@2x~ipad.png" 1536 2016
cropResize "$DEFAULT" "$SPLASH_PATH/Default-Portrait~ipad.png" 768 1024
cropResize "$DEFAULT" "$SPLASH_PATH/Default@2x~iphone.png" 640 960
cropResize "$DEFAULT" "$SPLASH_PATH/Default~iphone.png" 320 480

cropResize "$ICON" "$ICON_PATH/icon-72.png" 72 72 -flatten
cropResize "$ICON" "$ICON_PATH/icon-72@2x.png" 144 144 -flatten
cropResize "$ICON" "$ICON_PATH/icon.png" 57 57 -flatten
cropResize "$ICON" "$ICON_PATH/icon@2x.png" 114 114 -flatten

