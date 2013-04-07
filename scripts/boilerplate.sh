#!/bin/bash

function usage {
    echo 'usage: jackbone boilerplate <project-name>'
    echo
    echo 'Will create a new empty project in the <project-name> directory'
    exit 1
}

PROJECT_NAME=$2
if [ "x$PROJECT_NAME" = "x" ] || [ "x$PROJECT_NAME" = "xhelp" ]; then
    usage
fi

rsync -a $JACKBONEGAP_PATH/boilerplate/ $PROJECT_PATH/$PROJECT_NAME &&\
echo "Project created successfully in '$PROJECT_NAME/' directory."
