/**
 * @fileoverview Wrapper for backbone events.
 */
/* jshint maxlen:200 */
define([
    'jquery',
    'underscore',
    'backbone'
], function ($, _, Backbone) {
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
    var Events = _.extend({}, Backbone.Events);
    return Events;
});
