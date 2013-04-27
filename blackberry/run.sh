#!/bin/bash
if [ "x$target" = "xblackberry-10" ] || [ "x$target" = "xblackberry" ] || [ "x$target" = "xblackberry-playbook" ]; then
    set -e
    echo -e "Running for ${T_BOLD}BlackBerry.${T_RESET}"

    platform=`cat "$PROJECT_PATH/build/blackberry/platform"`
    BLACKBERRY_PROJECT_PATH="$PROJECT_PATH/build/blackberry/$PROJECT_NAME"

    if [ "x$2" != "x" ]; then
        platform="$2"
    fi

    if [ "x$conf" = "xrelease" ]; then
        ant_target="load-device"
    else
        ant_target="debug-device"
    fi

    cd "$BLACKBERRY_PROJECT_PATH"

    # Apply version number to config file
    VERSION=`cat $PROJECT_PATH/VERSION`
    BUILDNUM=`cat $BLACKBERRY_PROJECT_PATH/buildId.txt|grep number|cut -d= -f2`
    sed -i .bak "-e/\"[0-9].[0-9].[0-9].[0.9]\"/{;s/\"[0-9].[0-9].[0-9].[0.9]\"/\"$VERSION.$BUILDNUM.1\"/;:a" '-en;ba' '-e}' "www/config.xml"

    ant $platform $ant_target
fi

