#!/bin/bash
if [ x$BUILD_ANDROID = xYES ]; then

    echo -e "${T_BOLD}[BUILD] build/android${T_RESET}"

    which android && which adb || error "Please install Android SDK, make sure tools and platform-tools are in your PATH"

    ANDROID_PROJECT_PATH="$PROJECT_PATH/build/android/$PROJECT_NAME"
    WWW="$ANDROID_PROJECT_PATH/assets/www"

    if [ "x$conf" = "xwww" ] && test -e "$ANDROID_PROJECT_PATH"; then
        # Only rebuild www
        rsync -a build/www/ "$WWW"
        exit 0
    fi

    if [ "x$ANDROID_BUNDLE_ID" = "x" ]; then
        echo "ERROR: ANDROID_BUNDLE_ID not set in config file."
        exit 1
    fi

    BUNDLE_PATH=`echo $ANDROID_BUNDLE_ID | sed 's/\./\//g'`
    VERSION=`cat $PROJECT_PATH/VERSION`

    # Prepare Android project
    test -e "$ANDROID_PROJECT_PATH" || ./libs/phonegap/lib/android/bin/create "$ANDROID_PROJECT_PATH" $ANDROID_BUNDLE_ID "$PROJECT_NAME" || error "Android project creation failed"

    # Add custom build rules
    cp "$JACKBONEGAP_PATH/android/custom_rules.xml" "$ANDROID_PROJECT_PATH"/
    # Copy our own source files
    # cp "$JACKBONEGAP_PATH/android/DroidGap.java" "$ANDROID_PROJECT_PATH/src/$BUNDLE_PATH/$PROJECT_NAME.java"
    # Copy config
    cp "$JACKBONEGAP_PATH/android/config.xml" "$ANDROID_PROJECT_PATH/res/xml/config.xml"
    
    # Generate assets
    . "$JACKBONEGAP_PATH/android/generate-assets.sh" || error "Failed to generate Android assets"

    # Add version number
    V1=`echo $VERSION|cut -d. -f1`
    V2=`echo $VERSION|cut -d. -f2`
    if which xmlstarlet > /dev/null; then
        XMLSTARLET=`which xmlstarlet`
    else
        XMLSTARLET="$LIBS_PATH/xmlstarlet/xml"
    fi
    test -e "$XMLSTARLET" || error "Cannot find xmlstarlet, did you run 'jackbone init'?"
    "$XMLSTARLET" ed --inplace -u "/manifest/@android:versionName" -v "$V1.$V2" "$ANDROID_PROJECT_PATH/AndroidManifest.xml"
    if [ $V1 -lt 10 ]; then V1="0$V1"; fi
    if [ $V2 -lt 10 ]; then V2="0$V1"; fi
    "$XMLSTARLET" ed --inplace -u "/manifest/@android:versionCode" -v $V1$V2 "$ANDROID_PROJECT_PATH/AndroidManifest.xml"

    # Synchronize www
    rsync -a "$PROJECT_PATH/build/www/" "$WWW" || error "Android build failed"

    # Remove version number from cordova.js
    . "$JACKBONEGAP_PATH/package.sh" # PHONEGAP_VERSION is stored here.
    if test -e "$WWW/cordova-$PHONEGAP_VERSION.js"; then
        mv "$WWW/cordova-$PHONEGAP_VERSION.js" "$WWW/js/cordova.js"
    fi

    # Build
    if [ x$BUILD_RELEASE = xYES ]; then
        "$ANDROID_PROJECT_PATH"/cordova/release || error "Android build failed"
    else
        "$ANDROID_PROJECT_PATH"/cordova/build || error "Android build failed"
    fi
else
    echo "This script should be launched by jackbone."
    exit 1
fi
