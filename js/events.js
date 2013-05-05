/**
 * @fileoverview Wrapper for backbone events.
 */
/* jshint maxlen:200 */
define([
    'jquery',
    'underscore',
    'backbone',
    'logger'
], function ($, _, Backbone, Logger) {
    'use strict';
    /** 
    * @class [events] Central Events Dispatcher.
    * @name Events
    * @constructor
    * @description
    * Events is the central dispatcher of events, allowing modules to communicate with each other.
    *
    * Bellow is the raw list of events triggered by the application.
    * <ul>
    * <li><b>ui:disable</b> <ul><li>Triggered by Controllers when an long operation is in progress, to prevent user interactions.</li></ul></li>
    * <li><b>ui:enable</b> <ul><li>Triggered by Controllers to enable user interactions (usually follows 'ui:disable').</li></ul></li>
    * <li><b> </b>(<i> </i>) <ul><li>Triggered by X when Y.</li></ul></li>
    * </ul>
    */
    var Events = _.extend({
        debug: function (state) {
            if (state) {
                if (!this.oldTrigger) {
                    var t0 = (+new Date());
                    var oldTrigger = this.oldTrigger = this.trigger;
                    this.trigger = function (name) {
                        if (Logger && Logger.enabled) {
                            Logger.log('event: ' + name);
                        }
                        else {
                            console.log('[' + (+new Date() - t0) + '] event: ' + name);
                        }
                        oldTrigger.apply(this, arguments);
                    };
                }
            }
            else {
                if (this.oldTrigger) {
                    this.trigger = this.oldTrigger;
                    delete this.oldTrigger;
                }
            }
        }
    }, Backbone.Events);
    return Events;
});
