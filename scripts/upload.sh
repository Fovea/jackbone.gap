#!/bin/bash

function usage() {
    echo
    echo -e "usage: ${T_BOLD}jackbone upload${T_RESET} ${T_GREEN}<DistributionList> \"This build does this and that.\"${T_RESET}"
    echo
    echo -e "Make sur to add ${T_GREEN}TESTFLIGHT_API_TOKEN${T_RESET} and ${T_GREEN}TESTFLIGHT_TEAM_TOKEN${T_RESET} in your ${T_BOLD}config${T_RESET} file."
    echo
    exit 1
}

distribution_lists="$2"
notes="$3"
if [ "x$notes" = "x" ] || [ "x$note" = "xhelp" ] || [ "x$note" = "x--help" ]; then
    usage
fi
if [ "x$TESTFLIGHT_TEAM_TOKEN" = "x" ] || [ "x$TESTFLIGHT_API_TOKEN" = "x" ]; then
    usage
fi

# VERSION=`./version.sh print`
# . config
VERSION=`cat "$PROJECT_PATH/VERSION"`

APK="$PROJECT_PATH/archives/$PROJECT_NAME-$VERSION-Android.apk"
IPA="$PROJECT_PATH/archives/$PROJECT_NAME-$VERSION-iOS.ipa"
DSYM="$PROJECT_PATH/archives/$PROJECT_NAME-$VERSION-iOS.app.dSYM.zip"
BAR_PLAYBOOK="$PROJECT_PATH/archives/$PROJECT_NAME-$VERSION-BlackBerry-PlayBook.bar"
BAR_10="$PROJECT_PATH/archives/$PROJECT_NAME-$VERSION-BlackBerry-10.bar"
WEB="$PROJECT_PATH/archives/$PROJECT_NAME-$VERSION-Web"

if [ "x$BUILD_IOS" = "xYES" ] ; then
    test -e $DSYM && test -e $IPA && \
    curl http://testflightapp.com/api/builds.json \
        -F file="@$IPA" \
        -F dsym="@$DSYM" \
        -F api_token="$TESTFLIGHT_API_TOKEN" \
        -F team_token="$TESTFLIGHT_TEAM_TOKEN" \
        -F notes="$notes" \
        -F notify=False \
        -F distribution_lists="$distribution_lists"
    echo
fi

if [ "x$BUILD_ANDROID" = "xYES" ] ; then
    test -e $APK && \
    curl http://testflightapp.com/api/builds.json \
        -F file="@$APK" \
        -F api_token="$TESTFLIGHT_API_TOKEN" \
        -F team_token="$TESTFLIGHT_TEAM_TOKEN" \
        -F notes="$notes" \
        -F notify=False \
        -F distribution_lists="$distribution_lists"
    echo
fi
