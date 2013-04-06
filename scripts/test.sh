#!/bin/bash
PLATFORM=$1
if [ "x$PLATFORM" = "x" ]; then
    echo "usage: $0 <ios|web>"
    exit 1;
fi

# Retrieve dependencies
./configure.sh || exit 1

# Configure local IP as an authorized destination for AJAX calls.
if [ "x$PLATFORM" = "xios" ]; then
    if ! test -e config; then
        echo "Please create config file (use config-sample as a template)."
        exit 1
    fi
    echo $LOCAL_IP
fi

# Build
./build.sh $PLATFORM testing || exit 1

# Run
./run.sh $PLATFORM || exit 1

# Fine, we'll just see the result on screen...
exit 0

# The code bellow is working, but only if the web browser is allowed to send ajax request to this host/port.
# As of now, only Chrome does it.

# Prepare local server to retrieve test results
nc -l 2013 > test-results.txt &
NC_PID=$!
# In case results never gets sent, leave after 30 seconds.
( sleep 30 && kill $NC_PID ) >/dev/null 2>/dev/null &
wait $NC_PID

# Analyse the results.

# Extracts URL parameters into details
URI=`cat test-results.txt | grep /testDone | cut -d\  -f2 | cut -d\? -f2-`

if [ "x$URI" = "x" ]; then
    echo "No test results sent."
    exit 1
fi

saveIFS=$IFS
IFS='=&'
parm=($URI)
IFS=$saveIFS
for ((i=0; i<${#parm[@]}; i+=2)); do
    declare details_${parm[i]}=${parm[i+1]}
done

# Check details
echo "Test: \"`echo $details_name | sed 's/+/ /g'`\""
echo "      Failed: $details_failed / $details_total"
echo "      Passed: $details_passed / $details_total"

if [ $details_failed -gt 0 ]; then
    exit 1
fi
