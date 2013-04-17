#!/bin/bash

what=$2

function clean_build() {
    rm -fr build
    . "$JACKBONEGAP_PATH/android/clean.sh"
    . "$JACKBONEGAP_PATH/ios/clean.sh"
}

function clean_more() {
    # Clean VI backup files.
    find . -name '*~' -exec rm '{}' ';'
}

function clean_all() {
    rm -fr app/js/libs/ libs/ .downloads/
}

cd $PROJECT_PATH

if [ "x$what" = "xall" ]; then
    clean_build
    clean_more
    clean_all
elif [ "x$what" = "xmore" ]; then
    clean_build
    clean_more
elif [ "x$what" = "xbuild" ]; then
    clean_build
else
    echo "usage: jackbone clean <build|more|all>"
    echo
    echo "        build: only delete build files"
    echo "         more: delete build files and temporary files"
    echo "          all: delete build files, temporary files and downloaded files"
    echo
    exit 1
fi
