#!/bin/bash

#
# Build distribution archives for iOS, Android or Web.
# Put them in the archives/ folder.
#
# Set BUILD_IOS and BUILD_ANDROID to YES in config file
# to have iOS and/or Android archives generated.
# 

mkdir -p "$PROJECT_PATH/archives"
cd "$PROJECT_PATH"

VERSION=`cat VERSION`
if ! test -e "config"; then
    error "Please create config file (use config-sample as a template)"
fi

APK="$PROJECT_PATH/archives/$PROJECT_NAME-$VERSION-Android.apk"
IPA="$PROJECT_PATH/archives/$PROJECT_NAME-$VERSION-iOS.ipa"
DSYM="$PROJECT_PATH/archives/$PROJECT_NAME-$VERSION-iOS.app.dSYM.zip"
BAR_PLAYBOOK="$PROJECT_PATH/archives/$PROJECT_NAME-$VERSION-BlackBerry-PlayBook.bar"
BAR_10="$PROJECT_PATH/archives/$PROJECT_NAME-$VERSION-BlackBerry-10.bar"
WEB="$PROJECT_PATH/archives/$PROJECT_NAME-$VERSION-Web"

# Build for Web
"$JACKBONEGAP_PATH/jackbone" clean build       || exit 1 # Make sure we start from scratch
"$JACKBONEGAP_PATH/jackbone" build web release || exit 1 # Web Release Build
# Archive web version
rsync -a --delete "$PROJECT_PATH/build/www/" "$WEB"

# Build for iOS
if [ "x$BUILD_IOS" = "xYES" ] ; then
    IOS_PROJECT_PATH="$PROJECT_PATH/build/ios/$PROJECT_NAME"
    "$JACKBONEGAP_PATH/jackbone" clean build           || exit 1 # Restart from scratch
    "$JACKBONEGAP_PATH/jackbone" build ios-dev release || exit 1 # iOS Release Build
    # "$IOS_PROJECT_PATH/cordova/archive" || exit 1 # Archive

    # Archive the IPA and dSYM
    rm -fr "$IPA" "$DSYM" "$IOS_PROJECT_PATH/build/$PROJECT_NAME.app.dSYM.zip"
    cp "$IOS_PROJECT_PATH/build/$PROJECT_NAME.ipa" "$IPA"
    ( cd "$IOS_PROJECT_PATH/build/"; zip -r "$PROJECT_NAME.app.dSYM.zip" "$PROJECT_NAME.app.dSYM" ) || exit 1
    cp "$IOS_PROJECT_PATH/build/$PROJECT_NAME.app.dSYM.zip" "$DSYM"
fi

# Build for Android
if [ "x$BUILD_ANDROID" = "xYES" ] && which adb; then
    ANDROID_PROJECT_PATH="$PROJECT_PATH/build/android/$PROJECT_NAME"
    "$JACKBONEGAP_PATH/jackbone" clean build         || exit 1 # Restart from scratch
    "$JACKBONEGAP_PATH/jackbone" build android debug || exit 1 # Android Build
    cp "$ANDROID_PROJECT_PATH/bin/$PROJECT_NAME-debug.apk" "$APK"
fi

# Build for BlackBerry 
if [ "x$BUILD_BLACKBERRY" = "xYES" ]; then
    BLACKBERRY_PROJECT_PATH="$PROJECT_PATH/build/blackberry/$PROJECT_NAME"
    if [ "x$BUILD_BLACKBERRY_PLAYBOOK" = "xYES" ]; then
        "$JACKBONEGAP_PATH/jackbone" clean build         || exit 1
        "$JACKBONEGAP_PATH/jackbone" build blackberry-playbook release || exit 1
        cp "$BLACKBERRY_PROJECT_PATH/build/$PROJECT_NAME.bar" "$BAR_PLAYBOOK"
    fi
    if [ "x$BUILD_BLACKBERRY_10" = "xYES" ]; then
        "$JACKBONEGAP_PATH/jackbone" clean build         || exit 1
        "$JACKBONEGAP_PATH/jackbone" build blackberry-10 release || exit 1
        cp "$BLACKBERRY_PROJECT_PATH/build/device/$PROJECT_NAME.bar" "$BAR_10"
    fi
fi

# Statistics
echo -e "Archive ${T_GREEN}$PROJECT_NAME $VERSION${T_RESET} Done."
echo
if [ "x$BUILD_IOS" = "xYES" ]; then
    echo -e "${T_BOLD} IPA${T_RESET}: `du -hs $IPA`"
    echo -e "${T_BOLD}dSYM${T_RESET}: `du -hs $DSYM`"
fi
if [ "x$BUILD_ANDROID" = "xYES" ]; then
    echo -e "${T_BOLD} APK${T_RESET}: `du -hs $APK`"
fi
if [ "x$BUILD_BLACKBERRY" = "xYES" ]; then
    test -e "$BAR_PLAYBOOK" && echo -e "${T_BOLD} BAR${T_RESET}: `du -hs $BAR_PLAYBOOK`"
    test -e "$BAR_10" && echo -e "${T_BOLD} BAR${T_RESET}: `du -hs $BAR_10`"
fi
echo -e "${T_BOLD} Web${T_RESET}: `du -hs $WEB`"
echo
