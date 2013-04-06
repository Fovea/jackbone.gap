#!/bin/bash

#
# Build distribution archives for iOS, Android or Web.
# Put them in the archives/ folder.
#
# Set BUILD_IOS and BUILD_ANDROID to YES in config file
# to have iOS and/or Android archives generated.
# 

mkdir -p archives

cd `dirname $0`
VERSION=`./version.sh print`
if ! test -e config; then
    echo "Please create config file (use config-sample as a template)"
    exit 1
fi
. config

APK=./archives/Checklist-$VERSION-Android.apk
IPA=./archives/Checklist-$VERSION-iOS.ipa
DSYM=./archives/Checklist-$VERSION-iOS.app.dSYM.zip
WEB=./archives/Checklist-$VERSION-Web

# Build for Web
./clean.sh build       || exit 1 # Make sure we start from scratch
./build.sh web release || exit 1 # Web Release Build
# Archive web version
rsync -a --delete build/www/ $WEB

# Build for iOS
if [ "x$BUILD_IOS" = "xYES" ] ; then
    ./clean.sh build       || exit 1 # Restart from scratch
    ./build.sh ios release || exit 1 # iOS Release Build
    ./ios/checklist/cordova/archive || exit 1 # Archive

# Archive the IPA and dSYM
    rm -fr $IPA $DSYM ios/checklist/build/Checklist.app.dSYM.zip
    cp ./ios/checklist/build/Checklist.ipa $IPA
    ( cd ios/checklist/build/; zip -r Checklist.app.dSYM.zip Checklist.app.dSYM ) || exit 1
    cp ./ios/checklist/build/Checklist.app.dSYM.zip $DSYM
fi

if [ "x$BUILD_ANDROID" = "xYES" ] && which adb; then
    # Build for Android
    ./clean.sh build         || exit 1 # Restart from scratch
    ./build.sh android debug || exit 1 # Android Build
    cp ./android/checklist/bin/Checklist-debug.apk $APK
fi

# Statistics
echo "Archive Checklist $VERSION Done."
echo
if [ "x$BUILD_IOS" = "xYES" ]; then
    echo " IPA: `du -hs $IPA`"
    echo "dSYM: `du -hs $DSYM`"
fi
if [ "x$BUILD_ANDROID" = "xYES" ]; then
    echo " APK: `du -hs $APK`"
fi
echo " Web: `du -hs $WEB`"

