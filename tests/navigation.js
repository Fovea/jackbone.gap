/**
 * @fileoverview View manager.
 */
define([
    'jquery',
    'underscore',
    'jackbone',
    'events',
    'logger',
    'version',
    'templates',
    'testing'
], function ($, _, Jackbone, Events, Logger, Version, Templates, Testing) {
    'use strict';

    var HelloView = Jackbone.View.extend({
        render: function () {
            this.$el.html('<h1>Hello</h1>');
            this.$el.append('<input route="world" type="button" value="World">');
            this.$el.append('<input route="dummy" type="button" value="Dum Dum">');
        }
    });

    var WorldView = Jackbone.View.extend({
        render: function () {
            this.$el.html('<h1>World</h1>');
            this.$el.append('<input route="hello" type="button" value="Hello">');
            this.$el.append('<input route="dummy" type="button" value="Dum Dum">');
        }
    });

    var DummyView = Jackbone.View.extend({
        render: function () {
            this.$el.html('<h1>Dummy</h1>');
            this.$el.append('<p>I am a freaking dummy dialog.</p>');
            this.$el.append('<input route="back" type="button" value="OK">');
        }
    });

    var MyRouter = Jackbone.Router.extend({
        routes: {
            // Pages
            '':      'hello',
            'hello': 'hello',
            'world': 'world',
            'dummy': 'dummy',
            // Default - catch all
            '*actions': 'defaultAction'
        },
        hello: function () {
            this.openView({name: 'Hello', Class: HelloView});
        },
        world: function () {
            this.openView({name: 'World', Class: WorldView});
        },
        dummy: function () {
            this.openDialog({name: 'Dummy', Class: DummyView});
        }
    });

    var start = function (/* testingEnabled */) {
        var router = new MyRouter();
        Jackbone.history.start();
        router.goto('hello');
    };

    var pause = function () {
    };

    var resume = function () {
    };

    var test = function () {
        var T = Testing.Chain;
        var $a = function (selector) { return $(selector, $.mobile.activePage); };

        var okHello = function (msg) {
            T.add(0, 0,    function () { ok($a('h1').text() === 'Hello', msg); }, 1);
        };

        var okWorld = function (msg) {
            T.add(0, 0,    function () { ok($a('h1').text() === 'World', msg); }, 1);
        };

        var testHello = function () {
            okHello('Open Hello Window OK');
            testDummy();
            okHello('Back to Hello Window OK');
        };

        var testWorld = function () {
            okWorld('Open World Window OK');
            testDummy();
            okWorld('Back to World Window OK');
        };

        var testDummy = function () {
            T.add(0, 1000, function () { $a('input[route=dummy]').trigger('vclick', T.fakeEvent); });
            T.add(0, 0,    function () { ok($a('h1').text() === 'Dummy', 'Open Dummy Window OK'); }, 1);
            T.add(0, 1000, function () { $a('input[route=back]').trigger('vclick', T.fakeEvent); });
        };

        var openWorld = function () {
            T.add(0, 1000, function () { $a('input[route=world]').trigger('vclick', T.fakeEvent); });
        };

        QUnit.asyncTest('Navigation test 1', function (test) {
			T.init(test);
            testHello();
            openWorld();
            testWorld();
			T.finish();
        });

        T.start();
    };

    return {
        start: start,
        pause: pause,
        resume: resume,
        test: test
    };
});
