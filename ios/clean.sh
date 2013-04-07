#!/bin/bash

if [ x$what != x ]; then
    PROJECT_PATH=ios/checklist
    rm -fr $PROJECT_PATH
    # rm -fr $PROJECT_PATH/build $PROJECT_PATH/www
    # Uninstall Testflight plugin
    # if test -e ios/Checklist/Plugins/CDVTestFlight.m; then
    #    ./libs/plugman/plugman.js --remove --platform ios --project ios --plugin .downloads/TestflightPlugin
    # fi
fi
