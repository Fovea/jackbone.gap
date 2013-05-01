define([
    'jackbone'
], function (Jackbone) {

    'use strict';

    /** 
     * @name Testing
     * @class [tests/testing] Tests runner.
     * @constructor
     */
    var Testing = {};

    /** Run all the tests (after 1000 ms). */
    Testing.run = function (fn) {
        window.setTimeout(function () {
            fn();
            // QUnit.load();
        }, 1000);
    };

    /** 
     * @name TestChain
     * @class [tests/testchain] Tiny tool to chain asynchronous tests.
     * @constructor
     */
    var TestChain = Testing.Chain = {};

    /** Useful when generating fake clicks */
    TestChain.fakeEvent = { preventDefault: function () {} };

    /** Initialize the chain. */
    TestChain.init = function (test) {
        this.totalTime = (this.totalTime || 0) + (this.t || 0) + 1000;
        this.t = 2000;
        this.expected = 0;
        this.failed = false;
        this.test = test;
    };

    /** Add an element to the chain.
     * @param before Delay from previous action by an amount of milliseconds
     * @param after Delay to next action by an amount of milliseconds
     * @param fn        Function to call
     * @param nexpected Number of QUnit assertions expected (optional)
     */
    TestChain.add = function (before, after, fn, nexpected) {
        var test = this.test;
        this.t += before + 100;
        if (typeof nexpected === 'number') {
            this.expected += nexpected;
        }
        setTimeout(function () {
            if (!this.failed) {
                fn.call(test);
            }
        }, this.t);
        this.t += after + 100;
    };

    /** Launch execution of the chain.  */
    TestChain.finish = function () {
        QUnit.expect(this.expected);
    };

    TestChain.start = function () {
        QUnit.done(function (details) {
            console.log('QUnit.done:' + details.total +
                        ':' + details.failed +
                        ':' + details.passed +
                        ':' + details.runtime);
        });
        setTimeout(function () {
            Jackbone.router.goto('testing');
            setTimeout(function () {
                QUnit.start();
            }, 500);
        }, this.totalTime + this.t + 100);

        // Overload openView and openController so we get see feedback on the console.
        var oldOpenView = Jackbone.router.openView;
        var oldOpenController = Jackbone.router.openViewController;
        Jackbone.router.openView = function (name, C, o) {
            console.log(name + JSON.stringify(o));
            oldOpenView.apply(this, arguments);
        };
        Jackbone.router.openViewController = function (name, C, o) {
            console.log(name + JSON.stringify(o));
            oldOpenController.apply(this, arguments);
        };
    };
    return Testing;
});
