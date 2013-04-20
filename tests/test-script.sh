#!/bin/bash

set -e

if [ "x$TESTNAME" = "x" ]; then
    exit 1;
fi

cd `dirname $0`
JB=`pwd`/../jackbone
TESTDIR=`pwd`/../tmp
TESTFILE=`pwd`/$TESTNAME.js

test -e "$JB" || exit 1

mkdir -p "$TESTDIR"
cd "$TESTDIR"

# Generate / Update the project
"$JB" boilerplate test || exit 1
cd test || exit 1
cp config-sample config || exit 1
"$JB" update || exit 1

# Set the testing appdelegate
test -e "$TESTFILE" && cp "$TESTFILE" app/js/appdelegate.js || echo "$TESTFILE" not found... using default appdelegate.
"$JB" build web testing || exit 1

# Run the test
"$JB" run || exit 1

# XCode found, assume we're developing for iOS
if test -e /Developer/Applications/Xcode.app; then
    "$JB" build ios-dev testing
    "$JB" run
fi
