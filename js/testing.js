define([
    'qunit',
    'appdelegate'
], function(QUnit, AppDelegate) {
    /** 
     * @name Testing
     * @class [tests/testing] Tests runner.
     * @constructor
     */
    var Testing = {};

    /** Run all the tests (after 1000 ms). */
    Testing.run = function() {
        window.setTimeout(function() {
            AppDelegate.test();
            QUnit.load();
        }, 1000);
    };

    return Testing;
});
