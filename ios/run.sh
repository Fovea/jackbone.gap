#!/bin/bash
if [ "x$target" = "xios" ]; then
    IOS_PROJECT_PATH=$PROJECT_PATH/build/ios/$PROJECT_NAME
    if ! test -e $IOS_PROJECT_PATH/build/$PROJECT_NAME.app; then
        echo "$PROJECT_NAME.app not built yet."
        exit 1
    fi
    $IOS_PROJECT_PATH/cordova/run
fi
