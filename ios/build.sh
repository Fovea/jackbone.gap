#!/bin/bash
#
# This script should be launched by root dir's build script.
#
if [ "x$BUILD_IOS" = "xYES" ]; then

    echo -e "${T_BOLD}[BUILD] build/ios${T_RESET}"

    IOS_PROJECT_PATH="$PROJECT_PATH/build/ios/$PROJECT_NAME"

    if [ "x$conf" = "xwww" ] && test -e "$IOS_PROJECT_PATH"; then
        # Only rebuild www
        rsync -a build/www/ "$IOS_PROJECT_PATH/www"
        exit 0
    fi

    rm -fr "$PROJECT_PATH/build/ios"
    mkdir -p "$IOS_PROJECT_PATH"

    # Create PhoneGap iOS Project
    echo -n i
    "$LIBS_PATH/phonegap/lib/ios/bin/create" --shared "$IOS_PROJECT_PATH" "$IOS_BUNDLE_ID" "$PROJECT_NAME"

    # Patch the project.
    echo -n O
    patch -l -p0 << EOF > /dev/null || error "Patch failed"
--- $IOS_PROJECT_PATH/$PROJECT_NAME.xcodeproj/project.pbxproj	2013-03-23 09:24:16.000000000 +0200
+++ $IOS_PROJECT_PATH/$PROJECT_NAME.xcodeproj/project.pbxproj	2013-03-23 11:28:31.000000000 +0200
@@ -530,7 +530,7 @@
            CLANG_WARN_ENUM_CONVERSION = YES;
            CLANG_WARN_INT_CONVERSION = YES;
            CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
-				"CODE_SIGN_IDENTITY[sdk=iphoneos*]" = "iPhone Developer";
+				"CODE_SIGN_IDENTITY[sdk=iphoneos*]" = "$DEVELOPER_NAME";
            GCC_C_LANGUAGE_STANDARD = c99;
            GCC_THUMB_SUPPORT = NO;
            GCC_VERSION = com.apple.compilers.llvm.clang.1_0;
@@ -556,6 +556,7 @@
                "-all_load",
                "-Obj-C",
            );
+				"PROVISIONING_PROFILE[sdk=iphoneos*]" = "$PROVISIONING_PROFILE_ID";
            SDKROOT = iphoneos;
            SKIP_INSTALL = NO;
            USER_HEADER_SEARCH_PATHS = "";
EOF
    echo -n S
    if test -e "$PROJECT_PATH/ios/Info.plist"; then
        cp "$PROJECT_PATH/ios/Info.plist" "$IOS_PROJECT_PATH/$PROJECT_NAME/$PROJECT_NAME-Info.plist"
    fi
    cp "$JACKBONEGAP_PATH/ios/config.xml" "$IOS_PROJECT_PATH/$PROJECT_NAME/config.xml"
    cp "$JACKBONEGAP_PATH/ios/release-dev" "$IOS_PROJECT_PATH/cordova/release-dev"
    cp "$JACKBONEGAP_PATH/ios/build-dev" "$IOS_PROJECT_PATH/cordova/build-dev"

    # Generate icons and splash screens.
    echo -n .
    . "$JACKBONEGAP_PATH/ios/generate-assets.sh"

    # Remove useless assets.
    rm -fr "$PROJECT_PATH/www/res"

    # Install missing plugins.
    # Note: Some will not be installed for final distribution.
    cd "$PROJECT_PATH/build"
    echo -n .
    # INSTALL CDV TestFlight"
    "$JS_LIBS_PATH/plugman/plugman.js" --platform ios --project "$IOS_PROJECT_PATH" --plugin "$PROJECT_PATH/.downloads/TestflightPlugin" > "$EFILE" || error "Failed to install Testflight Plugin"

    echo -n .
    # INSTALL CDV SQLite"
    "$JS_LIBS_PATH/plugman/plugman.js" --platform ios --project "$IOS_PROJECT_PATH" --plugin "$PROJECT_PATH/.downloads/PhoneGap-SQLitePlugin-iOS/iOS" > "$EFILE" || error "Failed to install SQLite Plugin"
    rm "$EFILE"
    cd "$PROJECT_PATH"

    # Adjust the mess (lib install doesn't work... testflight.js file is unneeded)
    mkdir -p "$IOS_PROJECT_PATH/build"
    rm -fr "$IOS_PROJECT_PATH/www/testflight.js"
    cp "$DOWNLOADS_PATH/TestflightPlugin/src/ios/libTestFlight.a" "$IOS_PROJECT_PATH/build/"
    
    # Get default PhoneGap files
    # rsync -a build/ios/www/ ios/www
    # Patch them with our own files
    rsync -a build/www/ "$IOS_PROJECT_PATH/www"
    # Remove version number from cordova.js
    . "$JACKBONEGAP_PATH/package.sh" # PHONEGAP_VERSION is stored here.
    if test -e "$IOS_PROJECT_PATH/www/cordova-$PHONEGAP_VERSION.js"; then
        mv "$IOS_PROJECT_PATH/www/cordova-$PHONEGAP_VERSION.js" "$IOS_PROJECT_PATH/www/js/cordova.js"
    fi

    # Copy TestFlight lib to iOS folder... YAH
    # That's a bloody hack... but it works.
    for d in "~/Library/Developer/Xcode/DerivedData/$PROJECT_NAME"-*/Build/Products/Debug-iphoneos/; do
        test -e "$d" && cp "$IOS_PROJECT_PATH/build/libTestFlight.a" "$d"
    done

    if [ "x$target" = "xios-dev" ]; then
        devext="-dev"
    fi
    # Build
    if [ "x$BUILD_RELEASE" = "xYES" ]; then
        "$IOS_PROJECT_PATH/cordova/release$devext" | tee "$EFILE" | awk '{ if ((i = (i+1) % 16) == 0) { printf "."; fflush; } }' || error "iOS build failed"
    else
        "$IOS_PROJECT_PATH/cordova/build$devext"  | tee "$EFILE" | awk '{ if ((i = (i+1) % 16) == 0) { printf "."; fflush; } }' || error "iOS build failed"
    fi
    rm "$EFILE"

    echo ok
else
    echo "This script should be launched by root dir's build script."
    exit 1
fi

