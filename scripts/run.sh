#!/bin/bash

function usage() {
    echo "usage: jackbone run"
    exit 1
}

# Read command line options
target=`cat "$PROJECT_PATH/build/config" | cut -d\  -f1`
conf=`cat "$PROJECT_PATH/build/config" | cut -d\  -f2`

if [ "x$target" = "xweb" ] && [ "x$conf" = "xtesting" ]; then
    phantomjs tools/phantom-qunit-runner.js "$PROJECT_PATH/build/www/index.html"
elif [ "x$target" = "xweb" ]; then
    echo
    echo Just open file://$PROJECT_PATH/build/www/index.html
    echo
    echo Useful Chrome flags: --enable-memory-info --disable-web-security --allow-file-access-from-files
    echo Useful Safari: /Applications/Safari.app/Contents/MacOS/SafariForWebKitDevelopment
    echo
elif [ "x$target" = "xios-sim" ] || [ "x$target" = "xios-dev" ]; then
    . "$JACKBONEGAP_PATH/ios/run.sh" || exit 1
elif [ "x$target" = "xandroid" ]; then
    . "$JACKBONEGAP_PATH/android/run.sh" || exit 1
elif [ "x$target" = "xblackberry-10" ] || [ "x$target" = "xblackberry-qnx" ] || [ "x$target" = "xblackberry-playbook" ]; then
    . "$JACKBONEGAP_PATH/blackberry/run.sh" || exit 1
else
    usage
fi
