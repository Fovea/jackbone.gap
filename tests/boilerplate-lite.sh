#!/bin/bash

cd `dirname $0`
JB=`pwd`/../jackbone
TESTDIR=`pwd`/../tmp

test -e "$JB" || exit 1

mkdir -p "$TESTDIR"
cd "$TESTDIR"

if test ! -e boilerplate-test; then
    "$JB" boilerplate boilerplate-test || exit 1
    cd boilerplate-test || exit 1
    cp config-sample config || exit 1
    "$JB" init || exit 1
else
    cd boilerplate-test || exit 1
    "$JB" update || exit 1
fi

"$JB" build web testing || exit 1
"$JB" test web || exit 1
