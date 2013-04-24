#!/bin/bash
if [ "x$target" = "xblackberry-10" ] || [ "x$target" = "xblackberry-qnx" ] || [ "x$target" = "xblackberry-playbook" ]; then
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
    ant $platform $ant_target
fi

