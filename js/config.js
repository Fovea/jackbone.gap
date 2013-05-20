/* global module */
module.exports = {
    baseUrl: 'js',

    paths: {
        // Libraries
        jquery:        'libs/jquery/jquery',
        underscore:    'libs/underscore/underscore',
        backbone:      'libs/backbone/backbone',
        jquerymobile:  'libs/jquery.mobile/jquery.mobile',
        handlebars:    'libs/handlebars/dist/handlebars',
        testflight:    'libs/testflight',
        sqlite:        'libs/sqlite',
        emailcomposer: 'libs/emailcomposer',
        stacktrace:    'libs/stacktrace-js/stacktrace',
        jackbone:      'libs/jackbone/jackbone'
    },

    shim: {
        underscore: {
            exports: '_'
        },
        backbone: {
            deps: ['underscore', 'jquery'],
            exports: 'Backbone'
        },
        jquerymobile: {
            deps: ['jquery']
        },
        jackbone: {
            deps: ['backbone', 'jquerymobile'],
            exports: 'Jackbone'
        },
        handlebars: {
            exports: 'Handlebars'
        },
        stacktrace: {
            exports: 'printStackTrace'
        },
        emailcomposer: {
            exports: 'EmailComposer'
        }
    }
};
