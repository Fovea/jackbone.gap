if [ "x$TERM" = "xxterm" ] && which tput > /dev/null; then
    T_UNDER=`tput sgr 0 1`   # Underline
    T_BOLD=`tput bold`     # Bold
    T_RED=`tput setaf 1`   # red
    T_GREEN=`tput setaf 2` # green
    T_BLUE=`tput setaf 4`  # blue
    T_WHITE=`tput setaf 7` # white
    T_RESET=`tput sgr0`    # Reset
fi

function error() {
    test -e "$EFILE" && cat "$EFILE"
    echo -ne "$T_BOLD[ERROR] $T_RED"; echo -n "$1"; echo -e "$T_RESET"
    test "x$2" != "x" && echo -e "        $T_RED$2$T_RESET"
    test "x$3" != "x" && echo -e "        $T_RED$3$T_RESET"
    echo
    exit  1
}
