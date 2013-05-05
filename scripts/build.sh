#!/bin/bash

# Makes sure we're running from the project directory.
cd "$PROJECT_PATH"

function usage() {
    echo -e "usage: jackbone build ${T_GREEN}<target> <configuration>${T_RESET}"
    echo
    echo -e "Valid ${T_GREEN}targets${T_RESET} are:"
    echo -e " - ${T_BOLD}web${T_RESET}                  Web browsers"
    echo -e " - ${T_BOLD}ios-sim${T_RESET}              iOS simulator"
    echo -e " - ${T_BOLD}ios-dev${T_RESET}              iOS device"
    echo -e " - ${T_BOLD}android${T_RESET}              Any android"
    echo -e " - ${T_BOLD}blackberry-10${T_RESET}        BlackBerry 10"
    echo -e " - ${T_BOLD}blackberry-playbook${T_RESET}  BlackBerry Playbook"
    echo
    echo -e "Valid ${T_GREEN}configurations${T_RESET} are:"
    echo -e " - ${T_BOLD}debug${T_RESET}    Unoptimized development build"
    echo -e " - ${T_BOLD}release${T_RESET}  Optimized release build"
    echo -e " - ${T_BOLD}testing${T_RESET}  Automated tests"
    echo -e " - ${T_BOLD}www${T_RESET}      Re-build www folder only"
    echo
    exit 1
}

# If the project was already build once, let's use previous parameters as defaults.
if test -e "$PROJECT_PATH/build/config"; then
    target="`cat "$PROJECT_PATH/build/config" | cut -d\  -f1`"
    conf="`cat "$PROJECT_PATH/build/config" | cut -d\  -f2`"
fi

# Then read command line options
if [ "x$3" != "x" ]; then
    target="$2"
    conf="$3"
elif [ "x$2" != "x" ]; then
    usage
fi

if [ "x$target" = "xweb" ]; then
    BUILD_IOS=NO
    BUILD_ANDROID=NO
    BUILD_BLACKBERRY=NO
elif [ "x$target" = "xios-sim" ] || [ "x$target" = "xios-dev" ]; then
    BUILD_IOS=YES
    BUILD_ANDROID=NO
    BUILD_BLACKBERRY=NO
elif [ "x$target" = "xandroid" ]; then
    BUILD_IOS=NO
    BUILD_ANDROID=YES
    BUILD_BLACKBERRY=NO
elif [ "x$target" = "xblackberry-10" ] || [ "x$target" = "xblackberry" ] || [ "x$target" = "xblackberry-playbook" ]; then
    BUILD_IOS=NO
    BUILD_ANDROID=NO
    BUILD_BLACKBERRY=YES
else
    usage
fi

BUILD_RELEASE=NO
if [ "x$conf" = "xdebug" ] ; then
    BUILD_JS="optimize=none"
elif [ "x$conf" = "xrelease" ] || [ "x$conf" = "xwww" ]; then
    BUILD_RELEASE=YES
elif [ "x$conf" = "xtesting" ]; then
    BUILD_JS="optimize=none"
    BUILD_TESTING=YES
else
    usage
fi

echo -e "Building for target $T_GREEN$target$T_RESET, $T_GREEN$conf$T_RESET configuration."
echo "---------------------------------------------------"

# Store information about currently built configuration.
mkdir -p build
echo "$target $conf" > "$PROJECT_PATH/build/config"

# Prepare new directories
rm -fr ios/build
mkdir -p build/tmp
mkdir -p build/tmp-js
mkdir -p build/tmp-css
mkdir -p build/www/js
mkdir -p build/www/css

TMPJS=build/tmp-js
TMPCSS=build/tmp-css

echo -e "${T_BOLD}[BUILD] build/www${T_RESET}"

echo "Build date: `date`" > build/logs.txt

# Copy all our javascript to a temporary folder
rsync -a app/js/ build/tmp-js || error "Couldn't copy javascript"

# Compile Handlebars Templates
if test -x "$PROJECT_PATH/build-html.sh"; then
    "$PROJECT_PATH/build-html.sh" || error "Custom Build HTML"
fi
app/js/libs/handlebars/bin/handlebars app/html/*.html -f build/tmp/templates.js -k each -k if -k unless
# generate templates.js module using precompiled handlebars
sed -e '/TEMPLATES/r build/tmp/templates.js' "$JACKBONEGAP_PATH/js/templates.js.in" > "$TMPJS/templates.js"

# Install platform specific libraries
if [ "x$BUILD_IOS" = xYES ]; then
    cp "$DOWNLOADS_PATH/TestFlightPlugin/www/testflight.js" "$TMPJS/libs/testflight.js"
    cp "$DOWNLOADS_PATH/PhoneGap-SQLitePlugin-iOS/www/SQLitePlugin.js" "$TMPJS/libs/sqlite.js"
    cp "$DOWNLOADS_PATH/phonegap-plugins/iOS/EmailComposerWithAttachments/www/EmailComposer.js" "$TMPJS/libs/emailcomposer.js"
else
    # Empty files, so RequireJS finds something.
    # echo > app/js/libs/cordova.js
    echo > "$TMPJS/libs/testflight.js"
    echo > "$TMPJS/libs/sqlite.js"
    echo > "$TMPJS/libs/emailcomposer.js"
fi

# Copy version number to Javascript
VERSION="`cat VERSION`"
sed -e "s/__VERSION__/$VERSION/" "$JACKBONEGAP_PATH/js/version.js.in" | sed "s/__BUILD__/`date`/" | sed "s/__RELEASE__/$BUILD_RELEASE/" > "$TMPJS/version.js" || error "Failed to generate version.js"

# Copy Jackbone.gap JS files to Application
cp "$JACKBONEGAP_PATH/js/"*.js "$TMPJS/"

# Prepare CSS
if test -x "$PROJECT_PATH/build-css.sh"; then
    "$PROJECT_PATH/build-css.sh" || error "Custom Build CSS"
fi
rsync -a "$JACKBONEGAP_PATH/css/" "build/tmp-css" || error "Couldn't copy css"
rsync -a app/css/ build/tmp-css || error "Couldn't copy css"
cp -r "app/js/libs/jquery.mobile" "build/tmp-css/"
cat "$JACKBONEGAP_PATH/css/styles.css" | sed "s/PLATFORM/$target/" > "build/tmp-css/styles.css"

# Compile and Optimize Javascript / CSS
if [ "x$BUILD_RELEASE" == "xYES" ]; then
    LESS_OPTIONS="--yui-compress"
fi

echo -n J
node app/js/libs/requirejs/bin/r.js -o name='main' baseUrl="$TMPJS" out='build/www/js/main.js' findNestedDependencies=true mainConfigFile="$TMPJS/main.js" $BUILD_JS > build/tmp/jackbone.out || error "Javascript build failed"
echo -n a
node app/js/libs/requirejs/bin/r.js -o cssIn=build/tmp-css/styles.css out=build/tmp/styles.less > build/tmp/jackbone.out || error "CSS build failed"
echo -n c
node app/js/libs/less/bin/lessc $LESS_OPTIONS build/tmp/styles.less build/www/css/styles.css > build/tmp/jackbone.out || error "CSS build failed"
echo -n k
cp app/js/libs/requirejs/require.js build/www/js/require.js
cp "$JACKBONEGAP_PATH/js/worker-helper.js" build/www/js
rm -f build/tmp/jackbone.out
 
# Add "main.js" lines to itself.
echo -n b
if [ "x$BUILD_RELEASE" == "xYES" ]; then
    echo 'SOURCE_LINES = [];' >> build/www/js/main.js
else
    cp build/www/js/main.js build/tmp/main.js &&\
        cat build/tmp/main.js | sed "s/\"//g" | sed "s/'//g" | sed 's/\\//g' | tr -d '\r' |\
        awk 'BEGIN { print "SOURCE_LINES = ["; } { printf "\"%s\",\n", $0 } END { print "\"\"];" }' >> build/www/js/main.js
fi

echo -n o
if  [ "x$BUILD_TESTING" = "xYES" ]; then
    cp "$JACKBONEGAP_PATH/html/qunit.html" build/www/index.html
else
    sed "s/PROJECT_NAME/$PROJECT_NAME/" "$JACKBONEGAP_PATH/html/index.html" > build/www/index.html
fi

# Install Images
echo -n n
mkdir -p build/www/img
if test -x "$PROJECT_PATH/build-images.sh"; then
    "$PROJECT_PATH/build-images.sh" || error "Custom Build Images"
fi

echo -n e
if [ "x$BUILD_IMAGES" != "x" ]; then
    for i in $BUILD_IMAGES; do
        FILE=`echo $i | cut -d@ -f1`
        SIZE=`echo $i | cut -d@ -f2`
        W=`echo $SIZE | cut -dx -f1`
        if echo $SIZE | grep x > /dev/null; then
            H=`echo $SIZE | cut -dx -f2`
        else
            H=""
        fi
        echo -n .
        "$JACKBONEGAP_PATH/tools/buildimage.sh" "$FILE" $W $H || exit "Resizing $FILE failed"
    done
else
    rsync --delete -a app/img/ build/www/img || error "Could't copy images"
fi

echo -n .

if [ x$target = xweb ]; then
    "$JACKBONEGAP_PATH/web/generate-assets.sh"
fi

echo -n o
mkdir -p build/www/css/jquery.mobile/images
rsync -a app/js/libs/jquery.mobile/images/ build/www/css/jquery.mobile/images || error "Couldn't copy JQM images"
if [ "x$BUILD_TESTING" = "xYES" ]; then
    mkdir -p build/www/js/libs/qunitjs/qunit
    cp app/js/libs/qunitjs/qunit/qunit.css build/www/js/libs/qunitjs/qunit/qunit.css
fi
rm -f build/www/*.tmp

# Install Sounds
echo -n k
mkdir -p build/www/snd
if test -x "$PROJECT_PATH/build-sounds.sh"; then
    "$PROJECT_PATH/build-sounds.sh" || error "Custom Build Sounds"
fi
if test -e app/snd; then
    rsync --delete -a app/snd/ build/www/snd || error "Couldn't copy sounds"
fi

echo

# Compile iOS Application
if [ "x$BUILD_IOS" = "xYES" ]; then
    . "$JACKBONEGAP_PATH/ios/build.sh" || exit 1
fi

# Compile Android Application
if [ "x$BUILD_ANDROID" = "xYES" ]; then
    . "$JACKBONEGAP_PATH/android/build.sh" || exit 1
fi

# Compile Android Application
if [ "x$BUILD_BLACKBERRY" = "xYES" ]; then
    . "$JACKBONEGAP_PATH/blackberry/build.sh" || exit 1
fi

echo -e "${T_BOLD}[DONE]$T_RESET"
echo
echo -e "run $PROJECT_NAME with \"${T_BOLD}jackbone run${T_RESET}\""
echo
