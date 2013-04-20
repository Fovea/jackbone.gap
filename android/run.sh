#!/bin/bash
if [ "x$target" = "xandroid" ]; then

    function usage {
        echo
        echo "This is an Android build."
        echo "Please speficy if you want to run on a device or the emulator"
        echo
        echo "usage: jackbone run <device|emulator>"
        echo
        exit 1
    }

    if [ "x$2" != "x" ]; then
        mode="$2"
    else
        usage
    fi

    ANDROID_PROJECT_PATH="$PROJECT_PATH/build/android/$PROJECT_NAME"
    DEBUG_APK="$ANDROID_PROJECT_PATH/bin/$PROJECT_NAME-debug.apk"
    RELEASE_APK="$ANDROID_PROJECT_PATH/bin/$PROJECT_NAME-release.apk"

    if [ $mode = "device" ]; then
        if adb devices -l | grep 'usb:'; then
            echo "Android device found.";
        else
            echo "No Android device found.";
            exit 0
        fi
        adb_mode="-d"
    elif [ $mode = "emulator" ]; then
        adb_mode="-e"
    else
        usage
    fi

    if test -e "$DEBUG_APK" && ! test -e "$RELEASE_APK"; then
        echo "Installing Debug APK"
        adb $adb_mode install -r "$DEBUG_APK"
    elif test -e "$RELEASE_APK" && ! test -e "$DEBUG_APK"; then
        echo "Installing Release APK"
        adb $adb_mode install -r "$RELEASE_APK"
    elif test -e "$RELEASE_APK" && test -e "$DEBUG_APK" && test "$DEBUG_APK" -nt "$RELEASE_APK"; then
        echo "Installing Debug APK"
        adb $adb_mode install -r "$DEBUG_APK"
    elif test -e "$RELEASE_APK" && test -e "$DEBUG_APK" && test "$RELEASE_APK" -nt "$DEBUG_APK"; then
        echo "Installing Release APK"
        adb $adb_mode install -r "$RELEASE_APK"
    else
        echo "No APK built yet"
        exit 1
    fi
    echo "Running from your device"
    launch_str=$(java -jar "$ANDROID_PROJECT_PATH"/cordova/appinfo.jar "$ANDROID_PROJECT_PATH"/AndroidManifest.xml)
    adb $adb_mode shell am start -n "$launch_str"
    adb $adb_mode logcat -c

    if [ "x$conf" = "xtesting" ]; then
        (adb $adb_mode logcat | grep --line-buffered "CordovaLog" | awk -F: '{ if ($2 == " QUnit.done") { print "Tests total:", $3, " Failed:", $4, " Passed:", $5; system("sleep 1; killall adb"); exit ($4=="0"?0:1); } }') || exit 1
    else
        adb $adb_mode logcat | grep --line-buffered "CordovaLog" | cut -d\: -f2-
    fi
fi

