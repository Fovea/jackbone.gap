/**
 * @fileoverview Cordova Wrapper.
 */
define([
    'jquery',
    'underscore',
    'logger',
    'testflight'
], function ($, _, Logger) {
    'use strict';

    /**
     * Sets Cordova initial configuration, checks for supported features, loads plugins.
     * @name Cordova
     * @class [cdv] Cordova wrapper.
     * @constructor
     */
    var Cordova = {};
    
    /** Initialize Cordova Plugins. */
    Cordova.initialize = function() {
        if (typeof cordova !== 'undefined') {
            try {
                Cordova.testflight = cordova.require("cordova/plugin/testflightsdk");
            }
            catch (e) {
                Logger.log('TestFlight not found');
            }
            if (typeof Cordova.testflight !== 'undefined') {
                Cordova.testflight.setDeviceIdentifierUUID(function(){}, function(){});
                Cordova.testflight.takeOff(
                    function() { /* Win */  },
                    function() { /* Fail */ Cordova.testflight = false; },
                    "723945a1-4204-4c2a-82ac-63201cd6b20f"); // App Token

                $(window).error(function(e) {
                    if (Cordova.testflight !== false) {
                        // var file = e.originalEvent.filename + ":" + e.originalEvent.lineno;
                        var line = e.originalEvent.lineno;
                        var msg  = e.originalEvent.message;
                        var de = new Error('dummy');
                        var stack = de.stack.replace(/^[^\(]+?[\n$]/gm, '')
                            .replace(/^\s+at\s+/gm, '')
                            .replace(/^Object.<anonymous>\s*\(/gm, '{anonymous}()@')
                            .split('\n');
                        var decostack = 'Stacktrace:\n----------------\n' + stack + '\n----------------';
                        Cordova.testflight.remoteLog(function(){}, function(){}, "ERROR line " + line + ": " + msg + '\n' + decostack);
                    }
                });
            }
            else
                Cordova.testflight = false;
        }
        else
            Cordova.testflight = false;

        var ua = navigator.userAgent.toLowerCase();
        Cordova.isAndroid = ua.indexOf("android") > -1;
        Cordova.isIos = (navigator.userAgent.match(/(iPad|iPhone|iPod)/g) ? true : false);
    };

    /** Log a checkpoint in the application.
     * @param checkpointName String describing the checkpoint.
     */
    Cordova.passCheckpoint = function(checkpointName) {
        // Logger.log("[CHECKPOINT] " + checkpointName);
        if (Cordova.testflight !== false)
            Cordova.testflight.passCheckpoint(function(){}, function(){}, checkpointName);
    };

    /** Perform a subtle notification, like a vibration if supported. */
    Cordova.notify = function() {
        if (navigator && navigator.notification && navigator.notification.vibrate)
            navigator.notification.vibrate();
    };

    /** Show an alert dialog, with a title and a text. */
    Cordova.alert = function(title, txt) {
        if (navigator && navigator.notification && navigator.notification.alert)
            navigator.notification.alert(txt, function(){}, title);
        else
            alert(title + "\n" + txt);
    };

    /** Hide the native splash screen, if any. */
    Cordova.hideNativeSplash = function() {
        if (navigator && navigator.splashscreen && navigator.splashscreen.hide)
            navigator.splashscreen.hide();
    };

    /** Log a message, sends remotely to TestFlight.
     * @param message Text to log.
     */
    Cordova.log = function(message) {
        Logger.log(message);
        if (Cordova.testflight !== false && message)
            Cordova.remoteLog(function(){}, function(){}, message);
    };

    var soundLoadedSuccess = function () {};
    var sounds = {};

    /** Play a sound.
     * @param url of the sound.
     */
    Cordova.playSound = function(url) {
        // If Media API is supported.
        if (window.Media) {
            if (!sounds[url]) {
                var media = new Media(url, soundLoadedSuccess);
                sounds[url] = _.debounce(function () {
                    media.play({ playAudioWhenScreenIsLocked : false });
                }, 200, true);
            }
            sounds[url].call(this);
            // TODO: release sounds...
        }
    };

    // Debbugging remote calls to flightwatching server.
    // $(document).ajaxError(function(event, request, settings) {
    //     Cordova.passCheckpoint("AjaxError:" + settings.url);
    // });

    return Cordova;
});
