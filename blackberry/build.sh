#!/bin/bash
if [ x$BUILD_BLACKBERRY = xYES ]; then
    set -e

    echo -e "${T_BOLD}[BUILD] build/blackberry${T_RESET}"

    if [ "x$target" = "xblackberry-10" ]; then
        platform="blackberry"
    elif [ "x$target" = "xblackberry-qnx" ]; then
        platform="qnx"
    elif [ "x$target" = "xblackberry-playbook" ]; then
        platform="playbook"
    fi

    BLACKBERRY_PROJECT_PATH="$PROJECT_PATH/build/blackberry/$PROJECT_NAME"
    WWW="$BLACKBERRY_PROJECT_PATH/www"

    if [ "x$conf" = "xwww" ] && test -e "$BLACKBERRY_PROJECT_PATH"; then
        # Only rebuild www
        rsync -a build/www/ "$WWW"
        exit 0
    fi

    if [ "x$BLACKBERRY_BUNDLE_ID" = "x" ]; then
        echo "ERROR: BLACKBERRY_BUNDLE_ID not set in config file."
        exit 1
    fi

    BUNDLE_PATH=`echo $BLACKBERRY_BUNDLE_ID | sed 's/\./\//g'`
    VERSION=`cat $PROJECT_PATH/VERSION`

    # Prepare BlackBerry project
    test -e "$BLACKBERRY_PROJECT_PATH" || ./libs/phonegap/lib/blackberry/bin/create "$BLACKBERRY_PROJECT_PATH" $BLACKBERRY_BUNDLE_ID "$PROJECT_NAME" || error "BlackBerry project creation failed"

    # Synchronize www XXX
    rsync -a "$PROJECT_PATH/build/www/" "$WWW" || error "BlackBerry build failed"

    # Remove version number from cordova.js XXX
    . "$JACKBONEGAP_PATH/package.sh" # PHONEGAP_VERSION is stored here.
    if test -e "$WWW/cordova-$PHONEGAP_VERSION.js"; then
        mv "$WWW/cordova-$PHONEGAP_VERSION.js" "$WWW/js/cordova.js"
    fi

    if test ! -e "$PROJECT_PATH/blackberry/project.properties"; then
        mkdir -p "$PROJECT_PATH/blackberry"
        cp "$BLACKBERRY_BUNDLE_ID/project.properties" "$PROJECT_PATH/project.properties"
        error "Edit the blackberry/project.properties to configure BlackBerry SDK."
    fi
    cp "$PROJECT_PATH/blackberry/project.properties" "$BLACKBERRY_PROJECT_PATH/project.properties"

    if test -e "$PROJECT_PATH/blackberry/config.xml"; then
        cp "$PROJECT_PATH/blackberry/config.xml" "$WWW/config.xml"
    else
        sed -e "s|__PROJECT_NAME__|$PROJECT_NAME|" "$JACKBONEGAP_PATH/blackberry/config.xml" > "$WWW/config.xml"
    fi

    # XXX
    # Custom playbook.xml file fixes bug in phonegap generated playbook.xml file.
    # When p12.password and csk.password are identical, gen.password will be used.
    # This will hopefully be solved soon so this hack can be removed...
    cp "$JACKBONEGAP_PATH/blackberry/playbook.xml" "$BLACKBERRY_PROJECT_PATH/playbook.xml"

    # Build
    cd "$BLACKBERRY_PROJECT_PATH"
    ant $platform build

    # Store platform, for "run"
    echo $platform > "$PROJECT_PATH/build/blackberry/platform"
else
    echo "This script should be launched by jackbone."
    exit 1
fi
