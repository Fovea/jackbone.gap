#!/bin/bash

what=$1

function clean_build() {
    rm -fr build
    . android/clean.sh
    . ios/clean.sh
}

function clean_all() {
    rm -fr app/js/libs/ libs/ .downloads/
    # Clean VI backup files.
    find . -name '*~' -exec rm '{}' ';'
}

if [ "x$what" = "xall" ]; then
    clean_build
    clean_all
elif [ "x$what" = "xbuild" ]; then
    clean_build
else
    echo "usage: $0 <all|build>"
    echo
    echo "          all: delete build files and downloaded files"
    echo "        build: only delete build files"
    echo
    exit 1
fi
