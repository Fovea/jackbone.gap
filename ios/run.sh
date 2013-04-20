#!/bin/bash
IOS_PROJECT_PATH="$PROJECT_PATH/build/ios/$PROJECT_NAME"
if ! test -e "$IOS_PROJECT_PATH/build/$PROJECT_NAME.app"; then
    echo "$PROJECT_NAME.app not built yet."
    exit 1
fi

if [ "x$target" = "xios-sim" ]; then
    "$IOS_PROJECT_PATH/cordova/run"
elif [ "x$target" = "xios-dev" ]; then

    GDB_COMMANDS_FILE="/tmp/fruitstrap-gdb-commands"
    FRUITSTRAP="$DOWNLOADS_PATH/fruitstrap/fruitstrap"

    # Check if a device can be found
    "$FRUITSTRAP" -c -t 2 > /dev/null || NO_DEVICE=YES
    if [ "x$NO_DEVICE" = "xYES" ]; then
        echo "No device found."
        exit
    fi

    # Give time to previous fruitstrap instance to release the device.
    sleep 5

    if [ "x$conf" = "xtesting" ]; then
        cat << EOF > "$GDB_COMMANDS_FILE"
set confirm off
tbreak NSLog
continue
break NSLog if (int)[(id)\$r0 isEqualToString:@"[%@] %@"] == 1
command
    if ((int)[(id)\$r1 isEqualToString:@"LOG"] == 1)
        if ((int)[(id)\$r2 hasPrefix:@"QUnit.done"] == 1)
            po \$r2
            quit
        else
            continue
        end
    else
        continue
    end
end
continue
EOF
        STDOUT="$PROJECT_PATH/build/stdout.txt"
        "$FRUITSTRAP" -b "$IOS_PROJECT_PATH/build/$PROJECT_NAME.app" -t 5 -d -x "$GDB_COMMANDS_FILE" > "$STDOUT" 2>&1 || error "Failed to install to device"
        result=`cat "$STDOUT" | grep QUnit.done`
        [ "x$result" = "x" ] && exit 1
        total=`echo $result | cut -d: -f2`
        failed=`echo $result | cut -d: -f3`
        passed=`echo $result | cut -d: -f4`
        echo "QUnit Results:"
        echo "Total: $total, Failed: $failed, Passed: $passed"
        [ "x$failed" != "x0" ] && exit 1 || exit 0
    else
        echo 'continue' > "$GDB_COMMANDS_FILE"
        "$FRUITSTRAP" -b "$IOS_PROJECT_PATH/build/$PROJECT_NAME.app" -t 5 -d -x "$GDB_COMMANDS_FILE" || error "Failed to install to device"
    fi
fi
