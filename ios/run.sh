#!/bin/bash
if [ "x$target" = "xios" ]; then
    PROJECT_PATH=ios/checklist
    if ! test -e $PROJECT_PATH/build/Checklist.app; then
        echo "Checklist.app not built yet."
        exit 1
    fi
    ./$PROJECT_PATH/cordova/run
fi
