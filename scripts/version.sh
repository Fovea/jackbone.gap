#!/bin/bash

# Read number number from VERSION file.
# Adjust and apply version number to iOS project file.

VERSION=`cat VERSION`

cd `dirname $0`
V1=`echo $VERSION|cut -d. -f1`
V2=`echo $VERSION|cut -d. -f2`

if test -e config; then
    . config
fi

function usage
{
    echo usage: $0 "[major|minor|print|apply|force]"
    echo
    echo Use this script to increase the version number of the app.
    echo It also applies the Bundle ID defined in ./config.
    echo 
    echo "Examples:"
    echo "- Increase major number."
    echo $0 major
    echo "- Display version number on the console."
    echo $0 print
    echo "- Force version number to 2.8"
    echo $0 force 2.8
    echo

    exit 1
}

if [ "x$1" = "x" ]
then
    usage
elif [ "x$1" = "xmajor" ]
then
    V1=$((V1+1))
    V2=0
elif [ "x$1" = "xminor" ]
then
    V2=$((V2+1))
elif [ "x$1" = "xprint" ] || [ "x$1" = "xapply" ]
then
    echo > /dev/null
elif [ "x$1" = "xforce" ] && [ "x$2" != "x" ]
then
    V1=`echo $2|cut -d. -f1`
    V2=`echo $2|cut -d. -f2`
else
    usage
fi

if test -e /usr/libexec/PlistBuddy; then
    if [ "x$IOS_BUNDLE_ID" != "x" ]; then
        /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $IOS_BUNDLE_ID" ios/Checklist-Info.plist
    fi
    /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $V1.$V2" ios/Checklist-Info.plist
fi

echo $V1.$V2 > VERSION
echo $V1.$V2
