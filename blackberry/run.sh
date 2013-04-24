#!/bin/bash
if [ "x$target" = "xblackberry-10" ] || [ "x$target" = "xblackberry-qnx" ] || [ "x$target" = "xblackberry-playbook" ]; then
    set -e
    echo -e "Running for ${T_BOLD}BlackBerry.${T_RESET}"

    platform=`cat "$PROJECT_PATH/build/blackberry/platform"`
    BLACKBERRY_PROJECT_PATH="$PROJECT_PATH/build/blackberry/$PROJECT_NAME"

    if [ "x$2" != "x" ]; then
        platform="$2"
    fi

    cd "$BLACKBERRY_PROJECT_PATH"
    if [ "x$platform" = "xplaybook" ]; then
        ant playbook load-device
    elif [ "x$platform" = "xblackberry" ]; then
        ant blackberry load-device
    elif [ "x$platform" = "xqnx" ]; then
        ant qnx load-device
    else
        error "Unknown blackberry platform: $platform"
    fi
fi

