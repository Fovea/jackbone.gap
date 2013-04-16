// Allow to execute a function as a worker.
self.onmessage = function(e) {
    self.onmessage = null; // Clean-up
    eval(e.data);
};
