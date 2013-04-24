#!/bin/bash
if [ "x$target" = "xandroid" ]; then

    function usage {
        echo
        echo -e "${T_BOLD}This is an Android build.${T_RESET}"
        echo -e "Please speficy if you want to run on a ${T_GREEN}device${T_RESET} or the ${T_GREEN}emulator${T_RESET}"
        echo
        echo -e "usage: jackbone run <device|emulator> [<avd>|monkey]"
        echo -e "options:"
        echo -e "  - ${T_BOLD}device${T_RESET}     Run your app on a device connected on USB."
        echo -e "  - ${T_BOLD}emulator${T_RESET}   Run your app on a emulator."
        echo -e "    - <avd>    Launch the given avd if no emulators are running."
        echo -e "    - monkey   Start UI Exerciser Monkey mode."
        echo
        exit 1
    }

    function adb_restart {
        sleep 10
        echo "adb $adb_mode kill-server"
        adb $adb_mode kill-server || true
        sleep 1
        echo "adb $adb_mode start-server"
        adb $adb_mode start-server || true
        sleep 1
    }

    if [ "x$2" != "x" ]; then
        mode="$2"
    else
        usage
    fi

    # adb_restart

    ANDROID_PROJECT_PATH="$PROJECT_PATH/build/android/$PROJECT_NAME"
    DEBUG_APK="$ANDROID_PROJECT_PATH/bin/$PROJECT_NAME-debug.apk"
    RELEASE_APK="$ANDROID_PROJECT_PATH/bin/$PROJECT_NAME-release.apk"

    # Run on a device
    if [ $mode = "device" ]; then
        adb_mode="-d"

        # Check if there is a connected device.
        echo "adb devices"
        if adb devices -l | grep 'usb:'; then
            echo -e "${T_GREEN}Android device found.${T_RESET}";
        else
            echo -e "${T_RED}No Android device found.${T_RESET}";
            exit 0
        fi

    # Run on an emulator
    elif [ $mode = "emulator" ]; then
        adb_mode="-e"
        avd="$3"

        # Launch emulator if necessary
        if [ "x$avd" = "x" ] || [ "x$avd" = "xmonkey" ] || ps x|grep emulator|grep sdk|grep tools|grep "$avd" > /dev/null; then
            echo "Emulator already launched (or at least should be)."
        else
            echo -e "${T_BOLD}Starting emulator.${T_RESET}"
            echo "emulator -avd x86-4.2 -no-boot-anim"
            emulator -avd x86-4.2 -no-boot-anim &
        fi
    else
        usage
    fi

    # Sometime, adb will hung if we don't restart it properly.
    # adb_restart

    if test -e "$DEBUG_APK" && ! test -e "$RELEASE_APK"; then
        echo -e "${T_BOLD}Installing Debug APK${T_RESET}"
        echo "adb $adb_mode install -r $DEBUG_APK"
        adb $adb_mode install -r "$DEBUG_APK"
    elif test -e "$RELEASE_APK" && ! test -e "$DEBUG_APK"; then
        echo -e "${T_BOLD}Installing Release APK${T_RESET}"
        adb $adb_mode install -r "$RELEASE_APK"
    elif test -e "$RELEASE_APK" && test -e "$DEBUG_APK" && test "$DEBUG_APK" -nt "$RELEASE_APK"; then
        echo -e "${T_BOLD}Installing Debug APK${T_RESET}"
        adb $adb_mode install -r "$DEBUG_APK"
    elif test -e "$RELEASE_APK" && test -e "$DEBUG_APK" && test "$RELEASE_APK" -nt "$DEBUG_APK"; then
        echo -e "${T_BOLD}Installing Release APK${T_RESET}"
        adb $adb_mode install -r "$RELEASE_APK"
    else
        echo -e "${T_RED}No APK built yet${T_RESET}"
        exit 1
    fi

    launch_str=$(java -jar "$ANDROID_PROJECT_PATH"/cordova/appinfo.jar "$ANDROID_PROJECT_PATH"/AndroidManifest.xml)
    echo -e "Running ${T_BOLD}$launch_str${T_RESET} on $target"
    # adb_restart

    echo "adb $adb_mode shell am start -n $launch_str"
    adb $adb_mode shell am start -n "$launch_str"
    if [ "x$3" = "xmonkey" ]; then
        sleep 5
        adb $adb_mode shell monkey -p "$launch_str" -v 500
    fi
    echo "adb $adb_mode logcat -c"
    adb $adb_mode logcat -c

    if [ "x$conf" = "xtesting" ]; then
        echo "adb $adb_mode logcat"
        (adb $adb_mode logcat | grep --line-buffered "CordovaLog" | awk -F: '{ if ($2 == " QUnit.done") { print "Tests total:", $3, " Failed:", $4, " Passed:", $5; system("sleep 1; killall adb"); exit ($4=="0"?0:1); } }') || exit 1
    else
        adb $adb_mode logcat | grep --line-buffered "CordovaLog" | cut -d\: -f2-
    fi
fi

