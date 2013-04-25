#!/bin/bash
# Perform validation on source files.

SAVED_DIR=`pwd`
cd "$PROJECT_PATH"

# JSHint your javascript (exclude /libs/)
find "app/js" -name '*.js' -and -not -path '*/libs/*' -print0 | xargs -0 "$DOWNLOADS_PATH/node_modules/.bin/jshint" || error "Please fix all JSHint errors"

cd "$SAVED_DIR"
