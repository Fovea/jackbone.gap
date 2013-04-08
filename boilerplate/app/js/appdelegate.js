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
  'templates'
], function($, _, Jackbone, Events, Logger, Version, Templates) {

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
    };

    return {
        start: start,
        pause: pause,
        resume: resume,
        test: test
    };
});
