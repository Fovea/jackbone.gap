#!/bin/bash

DEPS="$PROJECT_PATH/deps.js"
CONF="$JACKBONEGAP_PATH/js/config.js"
F=/tmp/f.js

echo > $F
if test -e "$DEPS"; then
    echo 'var d = require("'$DEPS'");' >> $F
else
    echo 'var d = {};' >> $F
fi
echo 'var c = require("'$CONF'");' >> $F
cat << EOF >> $F
if (d.paths) {
    for (var i in d.paths) {
        c.paths[i] = d.paths[i];
    }
}

if (d.shim) {
    for (var i in d.shim) {
        c.shim[i] = d.shim[i];
    }
}
console.log("requirejs.config(" + JSON.stringify(c, null, '    ') + ");");
EOF

node $F > "$TMPJS/main.js"
cat "$JACKBONEGAP_PATH/js/main.js" >> "$TMPJS/main.js"
