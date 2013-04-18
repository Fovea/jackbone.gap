#!/bin/bash

# Makes sure we're running from the project directory.
cd "$PROJECT_PATH"

function usage() {
    echo "usage: jackbone build <web|ios|android> <debug|release|testing|www>"
    exit 1
}

# Read command line options
target="$2"
conf="$3"

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
    BUILD_JS="optimize=none"
elif [ "x$conf" = "xrelease" ] || [ "x$conf" = "xwww" ]; then
    BUILD_JS="optimize=none"
    BUILD_RELEASE=YES
elif [ "x$conf" = "xtesting" ]; then
    BUILD_TESTING=YES
else
    usage
fi

echo "$target $conf" > "$PROJECT_PATH/build/config"

rm -fr ios/build

mkdir -p build/tmp
mkdir -p build/tmp-js
mkdir -p build/tmp-css
mkdir -p build/www/js
mkdir -p build/www/css

TMPJS=build/tmp-js
TMPCSS=build/tmp-css

echo "[BUILD] build/www"

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
if [ x$BUILD_IOS = xYES ]; then
    cp .downloads/TestFlightPlugin/www/testflight.js "$TMPJS/libs/testflight.js"
    cp .downloads/PhoneGap-SQLitePlugin-iOS/iOS/www/SQLitePlugin.js "$TMPJS/libs/sqlite.js"
else
    # Empty files, so RequireJS finds something.
    # echo > app/js/libs/cordova.js
    echo > "$TMPJS/libs/testflight.js"
    echo > "$TMPJS/libs/sqlite.js"
fi

# Copy version number to Javascript
VERSION="`$JACKBONEGAP_PATH/jackbone version print`"
sed -e "s/__VERSION__/$VERSION/" "$JACKBONEGAP_PATH/js/version.js.in" \
    | sed "s/__BUILD__/`date`/" \
    | sed "s/__RELEASE__/$BUILD_RELEASE/" \
     > "$TMPJS/version.js"

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

echo -n r
node app/js/libs/requirejs/bin/r.js -o name='main' baseUrl="$TMPJS" out='build/www/js/main.js' findNestedDependencies=true mainConfigFile="$TMPJS/main.js" $BUILD_JS > build/tmp/jackbone.out || error "Javascript build failed"
echo -n r
node app/js/libs/requirejs/bin/r.js -o cssIn=build/tmp-css/styles.css out=build/tmp/styles.less > build/tmp/jackbone.out || error "CSS build failed"
echo -n r
node app/js/libs/less/bin/lessc $LESS_OPTIONS build/tmp/styles.less build/www/css/styles.css > build/tmp/jackbone.out || error "CSS build failed"
echo -n r
cp app/js/libs/requirejs/require.js build/www/js/require.js
cp "$JACKBONEGAP_PATH/js/worker-helper.js" build/www/js
rm -f build/tmp/jackbone.out
 
# Add "main.js" lines to itself.
if [ "x$BUILD_RELEASE" == "xYES" ]; then
    echo 'SOURCE_LINES = [];' >> build/www/js/main.js
else
    cp build/www/js/main.js build/tmp/main.js &&\
        cat build/tmp/main.js | sed "s/\"//g" | sed "s/'//g" | sed 's/\\//g' | tr -d '\r' |\
        awk 'BEGIN { print "SOURCE_LINES = ["; } { printf "\"%s\",\n", $0 } END { print "\"\"];" }' >> build/www/js/main.js
fi

if  [ "x$BUILD_TESTING" = "xYES" ]; then
    cp "$JACKBONEGAP_PATH/html/qunit.html" build/www/index.html
else
    sed "s/PROJECT_NAME/$PROJECT_NAME/" "$JACKBONEGAP_PATH/html/index.html" > build/www/index.html
fi

# Install Images
mkdir -p build/www/img
if test -x "$PROJECT_PATH/build-images.sh"; then
    echo -n i
    "$PROJECT_PATH/build-images.sh" || error "Custom Build Images"
fi
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
        echo -n i
        "$JACKBONEGAP_PATH/tools/buildimage.sh" "$FILE" $W $H || exit "Resizing $FILE failed"
    done
else
    rsync --delete -a app/img/ build/www/img || error "Could't copy images"
fi
if [ x$target = xweb ]; then
    "$JACKBONEGAP_PATH/web/generate-assets.sh"
fi

echo -n j
mkdir -p build/www/css/jquery.mobile/images
rsync -a app/js/libs/jquery.mobile/images/ build/www/css/jquery.mobile/images || error "Couldn't copy JQM images"
if [ "x$BUILD_TESTING" = "xYES" ]; then
    mkdir -p build/www/js/libs/qunitjs/qunit
    cp app/js/libs/qunitjs/qunit/qunit.css build/www/js/libs/qunitjs/qunit/qunit.css
fi
rm -f build/www/*.tmp

# Install Sounds
echo -n s
mkdir -p build/www/snd
if test -x "$PROJECT_PATH/build-sounds.sh"; then
    "$PROJECT_PATH/build-sounds.sh" || error "Custom Build Sounds"
fi
rsync --delete -a app/snd/ build/www/snd || error "Couldn't copy sounds"

echo

# Compile iOS Application
if [ "x$BUILD_IOS" = "xYES" ]; then
    . "$JACKBONEGAP_PATH/ios/build.sh" || exit 1
fi

# Compile Android Application
if [ "x$BUILD_ANDROID" = "xYES" ]; then
    . "$JACKBONEGAP_PATH/android/build.sh" || exit 1
fi

