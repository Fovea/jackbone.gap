#!/bin/bash

# Check that necessary tools are available
if ! which npm > /dev/null; then
    error "Please install NodeJS to retrieve dependencies." "http://nodejs.org/download/"
fi

if ! which git > /dev/null; then
    error "Please install Git to retrieve dependencies." "git-scm.com/"
fi

if ! which wget > /dev/null; then
    error "Please install wget to retrieve dependencies." \
            "- OSX: https://s3.amazonaws.com/techtach/files/wget/113/wget"
            "- Linux: apt-get install wget"
fi

if ! which make > /dev/null; then
    echo "Please install make in order to build iOS archives."
fi

# Package retrival methods

# GIT 
# Parameters: URL
function gitPackage {
    url="$1"
    name=`basename "$url" .git`
    if ! test -e "$DOWNLOADS_PATH/$name"; then
        ( cd "$DOWNLOADS_PATH"; git clone "$url" || exit 1) || error "Could not download $name"
    else
        ( cd "$DOWNLOADS_PATH/$name"; git pull || exit 1) || error "Could not update $name"
    fi
}

# HTTP
# Parameters URL OUTPUT_DIR
function httpPackageZIP {
    url="$1"
    outdir="$2"

    file=`echo "$url"|cut -d/ -f3-|sed 's/\//-/g'`

    if test ! -e "$DOWNLOADS_PATH/$file" || test ! -e "$outdir"; then
        test -e "$DOWNLOADS_PATH/$file" || wget --no-check-certificate -O "$DOWNLOADS_PATH/$file" "$url" || error "wget failed to download $url."
        rm -fr "$DOWNLOADS_PATH/tmp"
        mkdir -p "$DOWNLOADS_PATH/tmp"
        unzip "$DOWNLOADS_PATH/$file" -d "$DOWNLOADS_PATH/tmp/" > /dev/null || error "failed to unzip $file"
        rm -fr "$outdir"
        mv "$DOWNLOADS_PATH"/tmp/* "$outdir"
    fi
}

# Parameters URL OUTPUT_DIR
function httpPackageTGZ {
    url="$1"
    outdir="$2"

    file=`echo "$url"|cut -d/ -f3-|sed 's/\//-/g'`

    if test ! -e "$DOWNLOADS_PATH/$file" || test ! -e "$outdir"; then
        test -e "$DOWNLOADS_PATH/$file" || wget --no-check-certificate -O "$DOWNLOADS_PATH/$file" "$url" || error "wget failed to download $url."
        rm -fr "$DOWNLOADS_PATH/tmp"
        mkdir -p "$DOWNLOADS_PATH/tmp"
        (cd "$DOWNLOADS_PATH/tmp" ; tar xzf "$DOWNLOADS_PATH/$file" || exit 1) || error "failed to extract $file"
        rm -fr "$outdir"
        mv "$DOWNLOADS_PATH"/tmp/* "$outdir"
    fi
}

function httpPackageJS {
    url="$1"
    file="$2"

    mkdir -p `dirname "$file"`
    test -e "$file" || (wget --no-check-certificate -O "$file" "$url" || error "wget failed to download $file.")
}

# Clean version number from filenames
function cleanVersion {
    outdir="$1"
    version="$2"
    for i in "$outdir"/*; do
        NAME_WITHOUT_VERSION_NUMBER=`echo $i | sed "s/-$version//g"`
        if [ "x$i" != "x$NAME_WITHOUT_VERSION_NUMBER" ]; then
            mv "$i" "$NAME_WITHOUT_VERSION_NUMBER"
        fi
    done
}


