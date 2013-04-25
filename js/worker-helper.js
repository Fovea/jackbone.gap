// Allow to execute a function as a worker.
/* jshint evil: true */
self.onmessage = function(e) {
    self.onmessage = null; // Clean-up
    eval(e.data);
};
