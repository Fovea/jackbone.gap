#!/bin/bash

function usage {
    echo -e "usage: jackbone ${T_BOLD}boilerplate${T_RESET} ${T_GREEN}<project-name>${T_RESET}"
    echo
    echo -e "Will create a new empty project in the ${T_GREEN}<project-name>${T_RESET} directory"
    exit 1
}

PROJECT_NAME=$2
if [ "x$PROJECT_NAME" = "x" ] || [ "x$PROJECT_NAME" = "xhelp" ]; then
    usage
fi

rsync -a $JACKBONEGAP_PATH/boilerplate/ $PROJECT_PATH/$PROJECT_NAME &&\

echo -e "Project created successfully in ${T_BOLD}'$PROJECT_NAME/'${T_RESET} directory."
echo
echo -e "Next step, create your own ${T_GREEN}config${T_RESET} file from the ${T_GREEN}config-sample${T_RESET}, then type ${T_BOLD}jackbone init${T_RESET}"
echo
