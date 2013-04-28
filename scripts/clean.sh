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
    echo -e "usage: ${T_BOLD}jackbone clean${T_RESET} <${T_BOLD}build${T_RESET}|${T_BOLD}more${T_RESET}|${T_BOLD}all${T_RESET}>"
    echo
    echo -e "        ${T_BOLD}build${T_RESET}: only delete build files"
    echo -e "         ${T_BOLD}more${T_RESET}: delete build files and temporary files"
    echo -e "          ${T_BOLD}all${T_RESET}: delete build files, temporary files and downloaded files"
    echo
    exit 1
fi
