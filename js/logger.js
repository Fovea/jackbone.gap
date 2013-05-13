/**
 * @fileoverview JavaScript logging panel
 * @author mr.doob / http://mrdoob.com/
 * @author Jeko
 */
/* jshint nonew:false, maxstatements:33 */
/* global SOURCE_LINES */
define(['jquery', 'underscore', 'stacktrace'], function ($, _, Stacktrace) {
    'use strict';
    /**
     * @name Logger
     * @class [logger] JavaScript logging panel
     * @constructor
     */

    var Logger = {};
    var t0 = +new Date();

    Logger.enabled = true;

    Logger.initialize = function () {
        /* DOM element to be added to the document */
        Logger.el  = document.createElement('div');
        Logger.$el = $(Logger.el);
        Logger.logLines = [];
        /* Show only the last 'showLines' lines */
        Logger.showLines = 3;
        /* Enable error logging */
        $(window).error(function (e) {
            var msg  = e.originalEvent.message;
            Logger.error('L' + e.originalEvent.lineno + ':' + msg);
            Logger.logStacktrace();
            if (e.originalEvent.lineno) {
                var i = e.originalEvent.lineno - 10;
                if (i < 1) {
                    i = 1;
                }
                for (; i < e.originalEvent.lineno + 10 && i < SOURCE_LINES.length; ++i) {
                    Logger.log('Line ' + i + (i == e.originalEvent.lineno ? '--->' : ': ') + SOURCE_LINES[i - 1], 1);
                }
            }
            ++ Logger.numErrors;
        });
        var i;
        for (i = 0; i < Logger.showLines; ++i) {
            Logger.log(' ');
        }
        Logger.numErrors = 0;
    };

    Logger.setVmStats = function (vmstats) {
        this.vmStats = vmstats;
    };

    /** Renders the logs into the DOM element.
     * @param maxL */
    Logger.renderStats = function () {
        if (Logger.enabled) {
            if (!Logger.statsEl) {
                return;
            }
            Logger.$statsEl = $(Logger.statsEl);
            Logger.$statsEl.css('fontFamily', 'Helvetica, Arial, sans-serif');
            Logger.$statsEl.css('textAlign',  'left');
            Logger.$statsEl.css('fontSize',   '9px');
            Logger.$statsEl.css('padding',    '2px 0px 3px 0px');
            Logger.$statsEl.css('overflow-x', 'hidden');
            Logger.$statsEl.html('');

            if (Logger.numErrors) {
                Logger.$statsEl.append('<div><span style="color:#f88">Errors [' + Logger.numErrors + ']</span></div>');
            }
            else {
                Logger.$statsEl.append('<div>&nbsp;</div>');
            }

            var memUsed  = 0;
            var memTotal = 0;
            if (window.performance && window.performance.memory) {
                if (window.performance.memory.usedJSHeapSize) {
                    memUsed  = Math.round(window.performance.memory.usedJSHeapSize  / 100000) / 10;
                }
                if (window.performance.memory.totalJSHeapSize) {
                    memTotal = Math.round(window.performance.memory.totalJSHeapSize / 100000) / 10;
                }
            }

            if (memUsed + memTotal > 0) {
                Logger.$statsEl.append('<div>Memory [USED:' + memUsed + 'M] [TOTAL:' + memTotal + 'M]</div>');
            }
            else {
                Logger.$statsEl.append('<div>&nbsp;</div>');
            }

            var docStats = '[BODY:' + Math.floor($('body').html().length / 1000) + 'K]';

            if (this.vmStats) {
                docStats = '[VIEW:' + this.vmStats.numViews + ']' +
                 ' [CTRL:' + this.vmStats.numControllers + '] ' + docStats;
            }
            Logger.$statsEl.append('<div>Document ' + docStats + '</div>');
        }
    };

    /** Renders the logs into the DOM element.
     * @param maxL */
    Logger.render = function (maxLevel, reverse) {
        if (Logger.enabled) {
            var lmaxLevel = maxLevel || 0;
            var lreverse = reverse || 0;

            Logger.$el = $(Logger.el);
            Logger.$el.css('fontFamily', 'Helvetica, Arial, sans-serif');
            Logger.$el.css('textAlign',  'left');
            Logger.$el.css('fontSize',   '10px');
            Logger.$el.css('padding',    '2px 0px 3px 0px');
            Logger.$el.css('overflow-x', 'hidden');

            var lines = [];
            var i = Logger.logLines.length - 1;

            // Compute list of lines.
            while (i >= 0 && lines.length < Logger.showLines) {
                var line = Logger.logLines[i];
                if (line.level <= lmaxLevel) {
                    var tSeconds = Math.floor((line.t - t0) / 1000);
                    var tMinutes = Math.floor(tSeconds / 60);
                    tSeconds -= tMinutes * 60;
                    if (tSeconds < 10) {
                        tSeconds = '0' + tSeconds;
                    }
                    if (tMinutes < 10) {
                        tMinutes = '0' + tMinutes;
                    }
                    var t = tMinutes + ':' + tSeconds;
                    lines.push('<div>[' + t + '] ' + line.msg + '</div>');
                    if (lmaxLevel > 0) {
                        if (line.expand && line.msg instanceof Object) {
                            for (var param in line.msg) {
                                lines.push('<div>' + _.escape('- ' + param + ': ' + line.msg[param]) + '</div>');
                            }
                        }
                    }
                }
                --i;
            }

            // Display.
            if (!lreverse) {
                Logger.$el.html('');
                for (var j = lines.length; j-- > 0;) {
                    Logger.$el.append(lines[j]);
                }
            }
            else {
                Logger.$el.html(lines.join(''));
            }
        }
    };

    /** Set the elements where log are added.
     * @param e DOM element. */
    Logger.setElement = function (e) {
        Logger.el = e;
        Logger.$el = $(Logger.el);
    };

    /** Set the elements where stats are added.
     * @param e DOM element. */
    Logger.setStatsElement = function (e) {
        Logger.statsEl = e;
        Logger.$statsEl = $(Logger.statsEl);
    };

    /** Log something into the DOM element.
     * @param msg Text or object message
     * @param expand If true, msg is gonna be displayed as JSON.
     */
    Logger.log = function (msg, expand, lvl) {
        if (Logger.enabled) {
            Logger.logLines.push({t: +new Date(), msg: _.escape(msg), expand: expand, level: lvl || 0});
            // Logger.render();
            console.log(msg);
            // Keep maximum between 1000 and 2000 lines of log.
            if (Logger.logLines.length > 2000) {
                Logger.logLines = _(Logger.logLines).last(1000);
            }
            // Events.trigger('change:logs');
        }
    };

    /** Log an error into the DOM element.
     * @param msg Error message. */
    Logger.error = function (msg, lvl) {
        if (Logger.enabled) {
            var level = lvl || 0;
            Logger.logLines.push({
                t: +new Date(),
                msg: '<span style="color:#f88">' + _.escape(msg) + '</span>',
                expand: false,
                level: level
            });
            // Logger.render();
            console.log('ERROR: ' + msg);
            // Events.trigger('change:logs');
        }
    };

    /** Log stacktrace */
    Logger.logStacktrace = function () {
        Logger.error('Stack:', 1);
        Logger.error('------------------------', 1);
        var skipLines = 2;
        var stack = Stacktrace({e: new Error('dummy')});
        _(stack).each(function (line) {
            // Ignore first lines (logStacktrace itself)
            if (skipLines) {
                --skipLines;
            }
            else {
                Logger.error(line, 1);
            }
        });
        Logger.error('------------------------', 1);
    };

    /** Clear logs. */
    Logger.clear = function () {
        Logger.logLines = [];
        Logger.render();
    };

    return Logger;
});

/* vim: set ts=4 sw=4 tw=0 expandtab ft=javascript: */
