#!/bin/bash

cd `dirname $0` # Makes sure we're running from the current directory.

function error() {
    echo
    echo "[ERROR] $1"
    echo
    uname -a
    echo
    exit  1
}

function usage() {
    echo "usage: $0 <web|ios|android> <debug|release|testing|www>"
    exit 1
}

# Read command line options
target="$1"
conf="$2"

if [ "x$target" = "xweb" ]; then
    BUILD_IOS=NO
    BUILD_ANDROID=NO
elif [ "x$target" = "xios" ]; then
    BUILD_IOS=YES
    BUILD_ANDROID=NO
elif [ "x$target" = "xandroid" ]; then
    BUILD_IOS=NO
    BUILD_ANDROID=YES
else
    usage
fi

BUILD_RELEASE=NO
if [ "x$conf" = "xdebug" ] ; then
    BUILD_JS="build-debug.js"
elif [ "x$conf" = "xrelease" ] || [ "x$conf" = "xwww" ]; then
    BUILD_JS="build-release.js"
    BUILD_RELEASE=YES
elif [ "x$conf" = "xtesting" ]; then
    BUILD_JS="build-debug.js"
    BUILD_TESTING=YES
else
    usage
fi

rm -fr ios/build

# Compile Handlebars Templates
mkdir -p build/tmp
app/js/libs/handlebars/bin/handlebars app/html/*.html -f build/tmp/templates.js -k each -k if -k unless
# generate templates.js module using precompiled handlebars
sed -e '/TEMPLATES/r build/tmp/templates.js' app/js/templates.js.in > app/js/templates.js

# Install platform specific libraries
if [ x$BUILD_IOS = xYES ]; then
    cp .downloads/TestFlightPlugin/www/testflight.js app/js/libs/testflight.js
    cp .downloads/PhoneGap-SQLitePlugin-iOS/iOS/www/SQLitePlugin.js app/js/libs/sqlite.js
else
    # Empty files, so RequireJS finds something.
    # echo > app/js/libs/cordova.js
    echo > app/js/libs/testflight.js
    echo > app/js/libs/sqlite.js
fi

# Copy version number to Javascript
VERSION="`./version.sh print`"
sed -e "s/__VERSION__/$VERSION/" app/js/version.js.in \
    | sed "s/__BUILD__/`date`/" \
    | sed "s/__RELEASE__/$BUILD_RELEASE/" \
     > app/js/version.js

# Compile and Optimize Javascript / CSS
mkdir -p build/www/js
mkdir -p build/www/css
if [ x$BUILD_RELEASE == xYES ]; then
    LESS_OPTIONS="--yui-compress"
fi

( node app/js/libs/requirejs/bin/r.js -o $BUILD_JS &&\
  rm -fr build/tmp-css &&\
  cp -r app/css build/tmp-css &&\
  cp -r app/js/libs/jquery.mobile build/tmp-css/ &&\
  cat app/css/styles.css | sed "s/PLATFORM/$target/" > build/tmp-css/styles.css &&\
  node app/js/libs/requirejs/bin/r.js -o cssIn=build/tmp-css/styles.css out=build/tmp/styles.less &&\
  node app/js/libs/less/bin/lessc $LESS_OPTIONS build/tmp/styles.less build/www/css/styles.css &&\
  cp app/js/libs/requirejs/require.js build/www/js/require.js
) || error "Javascript build failed"
 
# Add "main.js" lines to itself.
if [ x$BUILD_RELEASE == xYES ]; then
    echo 'SOURCE_LINES = [];' >> build/www/js/main.js
else
    cp build/www/js/main.js build/tmp/main.js &&\
        cat build/tmp/main.js | sed "s/\"//g" | sed "s/'//g" | sed 's/\\//g' | tr -d '\r' |\
        awk 'BEGIN { print "SOURCE_LINES = ["; } { printf "\"%s\",\n", $0 } END { print "\"\"];" }' >> build/www/js/main.js
fi

if  [ "x$BUILD_TESTING" = "xYES" ]; then
    LOCAL_IP="127.0.0.1"
    [ "x$BUILD_IOS" = "xYES" ] && test -e config && . config
    sed "s/LOCAL_IP/$LOCAL_IP/" app/qunit.html > build/www/index.html
else
    cp app/index.html build/www/index.html
fi

# Install Images
mkdir -p build/www/img
rsync --delete -a app/img/ build/www/img
if [ x$target = xweb ]; then
    ./web/generate-assets.sh
fi

mkdir -p build/www/css/jquery.mobile/images
rsync -a app/js/libs/jquery.mobile/images/ build/www/css/jquery.mobile/images
if [ "x$BUILD_TESTING" = "xYES" ]; then
    mkdir -p build/www/js/libs/qunitjs/qunit
    cp app/js/libs/qunitjs/qunit/qunit.css build/www/js/libs/qunitjs/qunit/qunit.css
fi
rm -f build/www/*.tmp

# Compile iOS Application
if [ x$BUILD_IOS = xYES ]; then
    . ios/build.sh
fi

# Compile Android Application
if [ x$BUILD_ANDROID = xYES ]; then
    . android/build.sh
fi

