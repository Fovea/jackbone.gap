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
], function($, _, Jackbone, Events, Logger, Version, Templates, Testing) {

    var MenuView = Jackbone.View.extend({
        render: function () {
            $(this.el).html(Templates['menu.html']());
        }
    });

    var MyRouter = Jackbone.Router.extend({
        routes: {
            // Pages
            '':     'menu',
            'menu': 'menu',
            // Default - catch all
            '*actions': 'defaultAction'
        },
        menu: function () {
            this.openView('Menu', MenuView, {});
        }
    });

    var start = function (testingEnabled) {
        var router = new MyRouter();
        Jackbone.history.start();
        router.goto('menu');
    };

    var pause = function () {
    };

    var resume = function () {
    };

    var test = function () {
        QUnit.asyncTest("Application initialized", function (test) {
             Testing.Chain.init(test);
             Testing.Chain.add(   0, 1000, function () { Jackbone.router.goto('menu'); });
             Testing.Chain.add(   0,    0, function () { ok($('div[page-name=menu]').length === 1, 'Menu page exists'); }, 1);
             Testing.Chain.add(   0,    0, function () { ok($('h1', $.mobile.activePage).text() === 'Menu', 'Menu page opened'); }, 1);
             Testing.Chain.start();
        });
    };

    return {
        start: start,
        pause: pause,
        resume: resume,
        test: test
    };
});
