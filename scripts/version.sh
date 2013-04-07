#!/bin/bash

# Read number number from VERSION file.
# Adjust and apply version number to iOS project file.

test -e $PROJECT_PATH/VERSION || error "Please create VERSION file with a X.Y version number."
VERSION=`cat $PROJECT_PATH/VERSION`

cd $PROJECT_PATH
V1=`echo $VERSION|cut -d. -f1`
V2=`echo $VERSION|cut -d. -f2`

if test -e $PROJECT_PATH/config; then
    . $PROJECT_PATH/config
fi

function usage
{
    echo usage: jackbone version "[major|minor|print|apply|force]"
    echo
    echo Use this script to increase the version number of the app.
    echo It also applies the Bundle ID defined in ./config.
    echo 
    echo "Examples:"
    echo "- Increase major number."
    echo jackbone version major
    echo "- Display version number on the console."
    echo jackbone version print
    echo "- Force version number to 2.8"
    echo jackbone version force 2.8
    echo

    exit 1
}



if [ "x$2" = "x" ]
then
    usage
elif [ "x$2" = "xmajor" ]
then
    V1=$((V1+1))
    V2=0
elif [ "x$2" = "xminor" ]
then
    V2=$((V2+1))
elif [ "x$2" = "xprint" ] || [ "x$2" = "xapply" ]
then
    echo > /dev/null
elif [ "x$2" = "xforce" ] && [ "x$3" != "x" ]
then
    V1=`echo $3|cut -d. -f1`
    V2=`echo $3|cut -d. -f2`
else
    usage
fi

#if test -e /usr/libexec/PlistBuddy && test -e $PROJECT_PATH/ios/Info.plist; then
#    if [ "x$IOS_BUNDLE_ID" != "x" ]; then
#        /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $IOS_BUNDLE_ID" $PROJECT_PATH/ios/Info.plist
#    fi
#    /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $V1.$V2" $PROJECT_PATH/ios/Info.plist
#fi

echo $V1.$V2 > VERSION
echo $V1.$V2
