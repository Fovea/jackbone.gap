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
ICON_PATH="$ANDROID_PROJECT_PATH/res"

# DEFAULT=assets/Default.png 
# SPLASH_PATH=ios/checklist/Checklist/Resources/splash
# cropResize $DEFAULT $SPLASH_PATH/Default-568h@2x~iphone.png 639 1136
# cropResize $DEFAULT $SPLASH_PATH/Default-Landscape@2x~ipad.png 2048 1536
# cropResize $DEFAULT $SPLASH_PATH/Default-Landscape~ipad.png 1024 768
# cropResize $DEFAULT $SPLASH_PATH/Default-Portrait@2x~ipad.png 1536 2016
# cropResize $DEFAULT $SPLASH_PATH/Default-Portrait~ipad.png 768 1024
# cropResize $DEFAULT $SPLASH_PATH/Default@2x~iphone.png 640 960
# cropResize $DEFAULT $SPLASH_PATH/Default~iphone.png 320 480

DEFAULT="$PROJECT_PATH/assets/Default.png"
SPLASH_PATH="$WWW/img"

cropResize "$DEFAULT" "$SPLASH_PATH/splash.jpg" 1024 1024

cropResize "$ICON" "$ICON_PATH/drawable-hdpi/icon.png" 72 72
cropResize "$ICON" "$ICON_PATH/drawable/icon.png" 96 96
cropResize "$ICON" "$ICON_PATH/drawable-ldpi/icon.png" 36 36
cropResize "$ICON" "$ICON_PATH/drawable-mdpi/icon.png" 48 48
cropResize "$ICON" "$ICON_PATH/drawable-xhdpi/icon.png" 96 96
