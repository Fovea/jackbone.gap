/**
 * @fileoverview This module manages the SQL backend.
 *
 * Changed SQL backend to Web SQL,
 * as it's supported natively by iOS and Android
 * using an SQLite backend already.
 */
/* global Backbone */
define(["logger", "underscore", "events"/*, "sqlite"*/],
function (Logger, _, Events/*, SQLite*/) {
    "use strict";

    /**
     * Database initialization.
     *
     * @name Database
     * @class [database] Database management.
     * @constructor
     */
    var Database = _.extend({}, Backbone.Events);

    /** Open a database from its name.
     *
     * @param name Database name
     * @param collections List of all collections
     * @param callback Function called when the operation is done.
     */
    Database.open = function (name, collections, callback) {
        this.collections = collections;

        if (window.sqlitePlugin && window.sqlitePlugin.openDatabase) {
            Logger.log("Loading SQLite Plugin.");
            this.db = window.sqlitePlugin.openDatabase({name: name});
        }
        else {
            if (window.TESTING) {
                // Ask for 4MB of storage when testing (phantomjs fails above 5MB)
                this.db = openDatabase(name, "1.0", "Database " + name, 4 * 1024 * 1024);
            }
            else {
                // Ask for 100MB of storage!
                this.db = openDatabase(name, "1.0", "Database " + name, 100 * 1024 * 1024);
            }
        }

        var createOK = _.after(collections.length, callback);
        _.each(collections, function (c) {
            if (c.dbCreate) {
                c.dbCreate(createOK);
            } else {
                createOK();
            }
        });
    };

    /** Execute an SQL query on the database
     *
     * @param query SQL query string.
     * @param args array of parameters for the query.
     * @param callback a function taking an array of rows as argument.
     * @return JSON output. */
    Database.exec = function (query, args, callback) {
        var that = this;
        // Logger.log(query + " ["" + args.join("", "") + ""]", 0, 1);
        Events.trigger("database:busy");
        // _.defer(function() {
        that.db.transaction(function (tx) {
            tx.executeSql(query, args, function (tx, results) {
                var rows = [];
                var len = results.rows.length, i;
                for (i = 0; i < len; i++) {
                    rows.push(results.rows.item(i));
                }
                if (_.isFunction(callback)) {
                    callback(rows);
                    // _.defer(callback,rows);
                }
                Events.trigger("database:ok");
            },
            function (tx, error) {
                Events.trigger("database:ko");
                Logger.log("WebSQL ERROR: " + error.message);
            });
        });
        // });
    };

    /** Delete everything from the database.
     * @param callback Function called when the operation is done.
     */
    Database.reset = function (callback) {
        var opDone = _.after(this.collections.length, callback);
        _.each(this.collections, function (c) {
            // Create first (so drop don't fail)
            if (c.dbCreate && c.dbDrop) {
                c.dbCreate(function () { c.dbDrop(function () { c.dbCreate(opDone); }); });
            } else {
                opDone();
            }
        });
    };

    Database.enableSync  = true;

    /** Prototype for a collection using a database table */
    Database.Collection = Backbone.Collection.extend({
        /** Create table */
        dbCreate: function (callback) { callback(); },
        /** Drop table */
        dbDrop:   function (callback) {
            Database.exec("DROP TABLE " + this.dbStorage.name, [], callback);
        },
        /** Delete all entries from the table */
        dbClear: function (callback) {
            Database.exec("DELETE FROM " + this.dbStorage.name, [], callback);
        }
    });

    return Database;
});
