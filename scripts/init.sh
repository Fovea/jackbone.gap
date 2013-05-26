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

# Give user the chance to run some code before init.
if test -e "$PROJECT_PATH/scripts/pre-init.sh"; then
    echo "--- Pre-Init"
    cd "$PROJECT_PATH"
    . "$PROJECT_PATH/scripts/pre-init.sh"
fi

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

# Download and install JQuery
echo "--- JQuery"
httpPackageJS "$JQUERY_JS" "$JS_LIBS_PATH/jquery/jquery.js"

# Download and install Backbone.localStorage
echo "--- Backbone.localStorage"
httpPackageZIP "https://github.com/jeromegn/Backbone.localStorage/archive/master.zip" "$JS_LIBS_PATH/backbone.localstorage"

# Download GitHub's collection of PhoneGap plugins.
echo "--- PhoneGap Plugins"
gitPackage "https://github.com/j3k0/phonegap-plugins.git"

if [ "x$SYSTEM" = "xDarwin" ]; then

    # Download a few Cordova plugins that uses Plugman
    echo "--- TestFlight"
    gitPackage "https://github.com/j3k0/TestFlightPlugin.git"
    # httpPackageZIP "https://github.com/j3k0/TestFlightPlugin/archive/master.zip" "$LIBS_PATH/TestFlightPlugin"

    echo "--- SQLite iOS"
    gitPackage "https://github.com/j3k0/PhoneGap-SQLitePlugin-iOS.git"
    # httpPackageZIP "https://github.com/j3k0/PhoneGap-SQLitePlugin-iOS/archive/master.zip" "$LIBS_PATH/SQLitePlugin-iOS"

    # Download Fruitstrap, a tool to upload builds to an iOS device from command line
    echo "--- Fruitstrap"
    gitPackage "https://github.com/j3k0/fruitstrap.git"
    ( cd "$DOWNLOADS_PATH/fruitstrap" && make fruitstrap || exit 1) || error "Fruitstrap build failed"
fi

# SQLitePlugin for Android [NOT USED]
# echo "--- SQLite Android"
# gitPackage "https://github.com/brodyspark/PhoneGap-SQLitePlugin-Android.git"
# httpPackageZIP "https://github.com/brodyspark/PhoneGap-SQLitePlugin-Android/archive/master.zip" "$LIBS_PATH/SQLitePlugin-Android"

# XML Manipulation
if [ "x$BUILD_ANDROID" = "xYES" ]; then
    echo "--- XML Starlet"
    if which xmlstarlet > /dev/null; then
        echo "Found `which xmlstarlet`"
    else
        httpPackageTGZ "http://sourceforge.net/projects/xmlstar/files/latest/download" "$LIBS_PATH/xmlstarlet"
        if test ! -e "$LIBS_PATH/xmlstarlet/xml"; then
            ( cd "$LIBS_PATH/xmlstarlet" && ./configure && make || exit 1 ) > /dev/null || error "Failed to build xmlstarlet"
        fi
    fi
fi

if test -e "$PROJECT_PATH/package.json"; then
    echo "--- Project's NPM Packages"
    cd "$PROJECT_PATH"
    npm install || error "Failed to download project-specific NPM packages"
    if test -e node_modules; then
        rsync -a node_modules/ "$JS_LIBS_PATH" || error "Failed to install project-specific NPM packages"
    fi
fi

if test -e "$PROJECT_PATH/scripts/post-init.sh"; then
    echo "--- Post-Init"
    cd "$PROJECT_PATH"
    . "$PROJECT_PATH/scripts/post-init.sh"
fi

echo "--- DONE"

echo
echo -e "You can now build and test ${PROJECT_NAME} with ${T_BOLD}jackbone build${T_RESET}"
echo

