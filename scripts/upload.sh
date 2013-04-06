#!/bin/bash
notes=$1
if [ "x$notes" = "x" ]; then
    echo "usage $0 \"This build does this and that.\""
    exit 1
fi
VERSION=`./version.sh print`
. config

DSYM="archives/Checklist-$VERSION-iOS.app.dSYM.zip"
IPA="archives/Checklist-$VERSION-iOS.ipa"
APK="archives/Checklist-$VERSION-Android.apk"

test -e $DSYM && test -e $IPA && \
curl http://testflightapp.com/api/builds.json \
    -F file=@$IPA \
    -F dsym=@$DSYM \
    -F api_token='e9d037b7ac6b32804cc6dab2699df261_NTk4NDM3MjAxMi0wOC0yNyAxMDowODoxNi4xNDE5NTQ' \
    -F team_token='4c18e0b23d9314c49c7e4fc67fdc03be_MTkyODcwMjAxMy0wMi0yOCAxODozODowNC4wMTk2NTM' \
    -F notes="$notes" \
    -F notify=True \
    -F distribution_lists='Internal'
echo

test -e $APK && \
curl http://testflightapp.com/api/builds.json \
    -F file=@$APK \
    -F api_token='e9d037b7ac6b32804cc6dab2699df261_NTk4NDM3MjAxMi0wOC0yNyAxMDowODoxNi4xNDE5NTQ' \
    -F team_token='4c18e0b23d9314c49c7e4fc67fdc03be_MTkyODcwMjAxMy0wMi0yOCAxODozODowNC4wMTk2NTM' \
    -F notes="$notes" \
    -F notify=True \
    -F distribution_lists='Internal'
echo
