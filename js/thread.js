/**
 * @fileoverview Thread API, uses Web Workers if available, setTimeout if not.
 */

// Example usage:
//
// var thread = new Thread({
//     code: function () {
//         thread.onmessage = function(data) {
//             thread.postMessage('pong');
//         };
//     },
//     onMessage: function (data) {
//         alert(data);
//     }
// });
// thread.postMessage('ping');

define([], function () {

    'use strict';

    // Create a Thread from a function, which fully runs in its own scope
    var Thread = function (options) {
        this.options = options;
    };

    Thread.prototype.start = function () {
        var options = this.options;
        var func = options.code;

        // Stringify the code. Example:  (function(){/*logic*/}).call(self);
        // thread object added to abstract a little the fact that we're doing webworkers,
        // so we can provide fallbacks.
        var code = 'var ctx = self;';
        code    += 'self.onmessage = function(e) {';
        code    += 'if (ctx.onMessage) ctx.onMessage(e.data);';
        code    += '};';
        code    += '(' + func + ').call(self, ctx);';
        var worker = this.worker = new Worker('js/worker-helper.js');
        // Initialise worker
        worker.postMessage(code);
        worker.onmessage = function (e) {
            options.onMessage(e.data);
        };
        this.postMessage = function (data) {
            worker.postMessage(data);
        };
    };

    return Thread;
});
