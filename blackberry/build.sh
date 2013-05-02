#!/bin/bash
if [ x$BUILD_BLACKBERRY = xYES ]; then
    set -e

    echo -e "${T_BOLD}[BUILD] build/blackberry${T_RESET}"

    if [ "x$target" = "xblackberry-10" ]; then
        platform="qnx"
    elif [ "x$target" = "xblackberry" ]; then
        platform="blackberry"
    elif [ "x$target" = "xblackberry-playbook" ]; then
        platform="playbook"
    fi

    BLACKBERRY_PROJECT_PATH="$PROJECT_PATH/build/blackberry/$PROJECT_NAME"
    WWW="$BLACKBERRY_PROJECT_PATH/www"

    if [ "x$conf" = "xwww" ] && test -e "$BLACKBERRY_PROJECT_PATH"; then
        # Only rebuild www
        rsync -a build/www/ "$WWW"
        echo ok
        exit 0
    fi
    echo -n Bl

    if [ "x$BLACKBERRY_BUNDLE_ID" = "x" ]; then
        echo "ERROR: BLACKBERRY_BUNDLE_ID not set in config file."
        exit 1
    fi

    BUNDLE_PATH=`echo $BLACKBERRY_BUNDLE_ID | sed 's/\./\//g'`
    VERSION=`cat $PROJECT_PATH/VERSION`

    # Prepare BlackBerry project
    test -e "$BLACKBERRY_PROJECT_PATH" || ./libs/phonegap/lib/blackberry/bin/create "$BLACKBERRY_PROJECT_PATH" $BLACKBERRY_BUNDLE_ID "$PROJECT_NAME" || error "BlackBerry project creation failed"

    # Synchronize www
    echo -n a
    rsync -a "$PROJECT_PATH/build/www/" "$WWW" || error "BlackBerry build failed"

    # Remove version number from cordova.js
    echo -n c
    . "$JACKBONEGAP_PATH/package.sh" # PHONEGAP_VERSION is stored here.
    if test -e "$WWW/cordova-$PHONEGAP_VERSION.js"; then
        mv "$WWW/cordova-$PHONEGAP_VERSION.js" "$WWW/js/cordova.js"
    fi

    echo -n k
    if test ! -e "$PROJECT_PATH/blackberry/project.properties"; then
        mkdir -p "$PROJECT_PATH/blackberry"
        if test -e "$HOME/.jackbone/blackberry/project.properties"; then
            cp "$HOME/.jackbone/blackberry/project.properties" "$PROJECT_PATH/blackberry/project.properties"
        else
            cp "$BLACKBERRY_PROJECT_PATH/project.properties" "$PROJECT_PATH/blackberry/project.properties"
            error "Edit the blackberry/project.properties to configure BlackBerry SDK."
        fi
    fi
    cp "$PROJECT_PATH/blackberry/project.properties" "$BLACKBERRY_PROJECT_PATH/project.properties"

    echo -n Be
    if test -e "$PROJECT_PATH/blackberry/config.xml"; then
        cp "$PROJECT_PATH/blackberry/config.xml" "$WWW/config.xml"
    else
        sed -e "s|__PROJECT_NAME__|$PROJECT_NAME|" "$JACKBONEGAP_PATH/blackberry/config.xml" \
            | sed "s|__PROJECT_AUTHOR__|$PROJECT_AUTHOR|" \
            | sed "s|__PROJECT_DESCRIPTION__|$PROJECT_DESCRIPTION|" \
            > "$WWW/config.xml"
    fi

    # Apply version number and bundle ID to config file
    # Note that Bundle ID was removed from config.xml because it
    # caused PlayBook builds to fail.
    # That is why we add it only for the BlackBerry 10 target.
    if [ "x$target" = "xblackberry-10" ]; then
        ID_XML="id=\"$BLACKBERRY_BUNDLE_ID\""
    fi
    VERSION=`cat $PROJECT_PATH/VERSION`
    if test -e "$BLACKBERRY_PROJECT_PATH/buildId.txt"; then
        BUILDNUM=`cat $BLACKBERRY_PROJECT_PATH/buildId.txt|grep number|cut -d= -f2`
    else
        BUILDNUM=0;
    fi
    sed -i .bak "-e/\"[0-9].[0-9].[0-9].[0.9]\"/{;s/\"[0-9].[0-9].[0-9].[0.9]\"/\"$VERSION.$BUILDNUM.0\" $ID_XML/;:a" '-en;ba' '-e}' "$WWW/config.xml"

    # XXX
    # The custom playbook.xml file fixes a bug in phonegap generated playbook.xml file.
    # When p12.password and csk.password are identical, gen.password will be used.
    # This will hopefully be solved soon so this hack can be removed...
    # This hack is still necessary with PhoneGap version 2.5.0
    echo -n rr
    cp "$JACKBONEGAP_PATH/blackberry/playbook.xml" "$BLACKBERRY_PROJECT_PATH/playbook.xml"

    # Generate assets
    echo -n y
    . "$JACKBONEGAP_PATH/blackberry/generate-assets.sh" || error "Failed to generate Android assets"

    # Build
    cd "$BLACKBERRY_PROJECT_PATH"
    ant $platform build | tee "$EFILE" | awk '{ printf "."; fflush; }' || error "BlackBerry build failed"
    rm "$EFILE"

    # Store platform, for "run"
    echo $platform > "$PROJECT_PATH/build/blackberry/platform"
    echo ok
else
    echo "This script should be launched by jackbone."
    exit 1
fi
