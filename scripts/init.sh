#!/bin/bash
#
# Download and move dependencies to the appropriate location.
# 
# See package.json and package.sh for config
#

function error() {
    echo
    echo "[ERROR] $1"
    test "x$2" != "x" && echo "        $2"
    test "x$3" != "x" && echo "        $3"
    echo
    uname -a
    echo
    exit  1
}

test -e package.sh || error "package.sh not found."
test -e package.json || error "package.json not found."
. package.sh    # Load config

SYSTEM=`uname`

mkdir -p "$LIBS_PATH"
mkdir -p "$DOWNLOADS_PATH"

# Check that necessary tools are available
if ! which npm > /dev/null; then
    error "Please install NodeJS to retrieve dependencies." "http://nodejs.org/download/"
fi

if ! which wget > /dev/null; then
    error "Please install wget to retrieve dependencies." \
            "- OSX: https://s3.amazonaws.com/techtach/files/wget/113/wget"
            "- Linux: apt-get install wget"
fi

# Download and install dependencies available through NPM
echo "--- NPM Packages"
if ! test -e $JS_LIBS_PATH || ! test -e $DOWNLOADS_PATH/npmdone || test $JACKBONEGAP_PATH/package.json -nt $DOWNLOADS_PATH/npmdone; then
    cp $JACKBONEGAP_PATH/package.json $DOWNLOADS_PATH/
    cp $PROJECT_PATH/README.md $DOWNLOADS_PATH/
    (
      cd $DOWNLOADS_PATH;
      npm install || exit 1
      rsync -a node_modules/ $JS_LIBS_PATH || exit 1
    )  || error "NPM failed to retrieve dependencies."
    echo > $DOWNLOADS_PATH/npmdone
fi

# Download and install PhoneGap
echo "--- PhoneGap"
if ! test -e $LIBS_PATH/phonegap || [ `cat $LIBS_PATH/phonegap/VERSION` != $PHONEGAP_VERSION ]; then
    rm -fr $LIBS_PATH/phonegap
    test -e $DOWNLOADS_PATH/phonegap-$PHONEGAP_VERSION.zip || (wget --no-check-certificate -O $DOWNLOADS_PATH/phonegap-$PHONEGAP_VERSION.zip "$PHONEGAP_URL" || error "wget failed to download PhoneGap.")
    unzip $DOWNLOADS_PATH/phonegap-$PHONEGAP_VERSION.zip -d $DOWNLOADS_PATH > /dev/null
    mv $DOWNLOADS_PATH/phonegap-$PHONEGAP_VERSION $LIBS_PATH/phonegap
fi

# Download and install JQuery.Mobile
echo "--- JQuery.Mobile"
if ! test -e $JS_LIBS_PATH/jquery.mobile/jquery.mobile.js; then
    wget -O $DOWNLOADS_PATH/jquery.mobile-$JQUERYMOBILE_VERSION.zip "$JQUERYMOBILE_URL"
    unzip $DOWNLOADS_PATH/jquery.mobile-$JQUERYMOBILE_VERSION.zip -d $DOWNLOADS_PATH > /dev/null || error "Could not extract jquery.mobile file"
    mv $DOWNLOADS_PATH/jquery.mobile-$JQUERYMOBILE_VERSION $JS_LIBS_PATH/jquery.mobile
    for i in $JS_LIBS_PATH/jquery.mobile/*; do
        NAME_WITHOUT_VERSION_NUMBER=`echo $i | sed "s/-$JQUERYMOBILE_VERSION//g"`
        mv $i $NAME_WITHOUT_VERSION_NUMBER
    done
fi

# Download and install Kinetic
echo "--- Kinetic"
if ! test -e $JS_LIBS_PATH/kinetic.js; then
    wget -O $JS_LIBS_PATH/kinetic.js "$KINETIC_JS" || error "wget failed to download kinetic.js"
fi

# Download and install JQuery
echo "--- JQuery"
if ! test -e $JS_LIBS_PATH/jquery/jquery.js; then
    mkdir -p $JS_LIBS_PATH/jquery
    wget -O $JS_LIBS_PATH/jquery/jquery.js "$JQUERY_JS" || error "wget failed to download jquery.js"
fi

# Download and install Backbone.localStorage
# [ NOT USED ]
if ! test -e $JS_LIBS_PATH/backbone.localstorage/backbone.localStorage.js; then
    mkdir -p $JS_LIBS_PATH/backbone.localstorage/
    wget --no-check-certificate -O $DOWNLOADS_PATH/backbone.localstorage.zip https://github.com/jeromegn/Backbone.localStorage/archive/master.zip || error "wget failed to download backbone.localstorage"
    unzip $DOWNLOADS_PATH/backbone.localstorage -d $DOWNLOADS_PATH > /dev/null
    mv $DOWNLOADS_PATH/Backbone.localStorage-master/backbone.localStorage*.js $JS_LIBS_PATH/backbone.localstorage/
fi

# Download and install Plugman (Cordova plugin manager)
echo "--- Plugman"
if ! test -e $LIBS_PATH/plugman; then
    ( cd $LIBS_PATH && git clone https://github.com/imhotep/plugman.git && cd plugman && npm install || exit 1 ) || error "Could not install Plugman"
fi

function gitPull {
    url="$1"
    name=`basename "$url" .git`
    if ! test -e $DOWNLOADS_PATH/$name; then
        ( cd $DOWNLOADS_PATH; git clone $url || exit 1) || error "Could not download $name Plugin"
    else
        ( cd $DOWNLOADS_PATH/$name; git pull || exit 1) || error "Could not update $name Plugin"
    fi
}

# Download a few Cordova plugins that uses Plugman
if [ "x$SYSTEM" = "xDarwin" ]; then
    echo "--- TestFlight"
    gitPull "git://github.com/j3k0/TestFlightPlugin.git"
    echo "--- SQLite iOS"
    gitPull "git://github.com/j3k0/PhoneGap-SQLitePlugin-iOS.git"
fi
echo "--- SQLite Android"
gitPull "git://github.com/brodyspark/PhoneGap-SQLitePlugin-Android.git"

echo "--- DONE"
