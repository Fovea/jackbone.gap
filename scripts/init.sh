#!/bin/bash
#
# Download and move dependencies to the appropriate location.
# 
# See package.json and package.sh for config
#

test -e package.sh || error "package.sh not found."
test -e package.json || error "package.json not found."

# Load config
. package.sh

# Load package manager methods
. "$JACKBONEGAP_PATH/tools/package-manager.sh"

SYSTEM=`uname`

mkdir -p "$LIBS_PATH"
mkdir -p "$DOWNLOADS_PATH"

# Download and install dependencies available through NPM
echo "--- NPM Packages"
if ! test -e "$JS_LIBS_PATH" || ! test -e "$DOWNLOADS_PATH/npmdone" || test "$JACKBONEGAP_PATH/package.json" -nt "$DOWNLOADS_PATH/npmdone"; then
    cp "$JACKBONEGAP_PATH/package.json" "$DOWNLOADS_PATH/"
    cp "$PROJECT_PATH/README.md" "$DOWNLOADS_PATH/"
    (
      cd "$DOWNLOADS_PATH";
      npm install || exit 1
      rsync -a node_modules/ "$JS_LIBS_PATH" || exit 1
    )  || error "NPM failed to retrieve dependencies."
    echo > "$DOWNLOADS_PATH/npmdone"
fi

# Download and install PhoneGap
echo "--- PhoneGap"
httpPackageZIP "$PHONEGAP_URL" "$LIBS_PATH/phonegap"

# Download and install JQuery.Mobile
echo "--- JQuery.Mobile"
httpPackageZIP "$JQUERYMOBILE_URL" "$JS_LIBS_PATH/jquery.mobile"
cleanVersion "$JS_LIBS_PATH/jquery.mobile" "$JQUERYMOBILE_VERSION"

# Download and install Kinetic
echo "--- Kinetic"
httpPackageJS "$KINETIC_JS" "$JS_LIBS_PATH/kinetic.js"

# Download and install JQuery
echo "--- JQuery"
httpPackageJS "$JQUERY_JS" "$JS_LIBS_PATH/jquery/jquery.js"

# Download and install Backbone.localStorage
echo "--- Backbone.localStorage"
httpPackageZIP "https://github.com/jeromegn/Backbone.localStorage/archive/master.zip" "$JS_LIBS_PATH/backbone.localstorage"

# Download GitHub's collection of PhoneGap plugins.
# echo "--- PhoneGap Plugins"
# gitPackage "git://github.com/phonegap/phonegap-plugins.git"

if [ "x$SYSTEM" = "xDarwin" ]; then

    # Download a few Cordova plugins that uses Plugman
    echo "--- TestFlight"
    gitPackage "git://github.com/j3k0/TestFlightPlugin.git"

    echo "--- SQLite iOS"
    gitPackage "git://github.com/j3k0/PhoneGap-SQLitePlugin-iOS.git"

    # Download Fruitstrap, a tool to upload builds to an iOS device from command line
    echo "--- Fruitstrap"
    gitPackage "git://github.com/j3k0/fruitstrap.git"
    ( cd "$DOWNLOADS_PATH/fruitstrap" && make fruitstrap || exit 1) || error "Fruitstrap build failed"
fi

# SQLitePlugin for Android [NOT USED]
echo "--- SQLite Android"
gitPackage "git://github.com/brodyspark/PhoneGap-SQLitePlugin-Android.git"

# XML Manipulation
echo "--- XML Starlet"
httpPackageTGZ "http://sourceforge.net/projects/xmlstar/files/latest/download" "$LIBS_PATH/xmlstarlet"
if test ! -e "$LIBS_PATH/xmlstarlet/xml"; then
    ( cd "$LIBS_PATH/xmlstarlet" && ./configure && make || exit 1 ) > /dev/null || error "Failed to build xmlstarlet"
fi

echo "--- DONE"

echo
echo -e "You can now build and test ${PROJECT_NAME} with ${T_BOLD}jackbone build${T_RESET}"
echo

