// Allow to execute a function as a worker.
/* jshint evil: true */
/* global self */
self.onmessage = function (e) {
    'use strict';
    self.onmessage = null; // Clean-up
    eval(e.data);
};
