#!/bin/bash

function usage() {
    echo "usage: jackbone run <web|ios|android>"
    exit 1
}

# Read command line options
target="$2"

if [ "x$target" = "xweb" ]; then
    echo
    echo Just open file://`pwd`/build/www/index.html
    echo
    echo Useful Chrome flags: --enable-memory-info --disable-web-security --allow-file-access-from-files
    echo Useful Safari: /Applications/Safari.app/Contents/MacOS/SafariForWebKitDevelopment
    echo
elif [ "x$target" = "xios" ]; then
    . $JACKBONEGAP_PATH/ios/run.sh
elif [ "x$target" = "xandroid" ]; then
    . $JACKBONEGAP_PATH/android/run.sh
else
    usage
fi
