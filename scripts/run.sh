#!/bin/bash

cd `dirname $0` # Makes sure we're running from the current directory.

function usage() {
    echo "usage: $0 <web|ios|android>"
    exit 1
}

# Read command line options
target="$1"

if [ "x$target" = "xweb" ]; then
    # SAFARIDEV="/Applications/Safari.app/Contents/MacOS/SafariForWebKitDevelopment"
    # if test -e $SAFARIDEV; then
    # $SAFARIDEV build/www/index.html &
    # else
    echo open /Applications/Google\ Chrome.app --args --enable-memory-info --disable-web-security file://`pwd`/build/www/index.html
    open /Applications/Google\ Chrome.app --args --enable-memory-info --disable-web-security file://`pwd`/build/www/index.html
    # fi
elif [ "x$target" = "xios" ]; then
    . ios/run.sh
elif [ "x$target" = "xandroid" ]; then
    . android/run.sh
else
    usage
fi
