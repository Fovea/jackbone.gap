/**
 * @fileoverview Backbone Database Adapter.
 * @author Jean-Christophe Hoelt
 * @version 0.1
 * @description A simple module to replace `Backbone.sync` with *Database*-based persistence.
 */

// Developped based upon Backbone.localStorage.

/* global $ */

define(["underscore", "backbone", "database"], function (_, Backbone, Database) {
    "use strict";

    /** Generate four random hex digits. */
    function S4() {
        return (((1 + Math.random()) * 0x10000) | 0).toString(16).substring(1);
    }

    /** Generate a pseudo-GUID by concatenating random hexadecimal. */
    function guid() {
        return (S4() + S4() + "-" + S4() + "-" + S4() + "-" + S4() + "-" + S4() + S4() + S4());
    }

    /** Returns the array of values for a model.
    * @param columns Array of columns names
    * @param model The Backbone model.
    */
    function modelValues(columns, model) {
        var ret = [];
        _(columns).each(function (c) {
            if (model.has(c)) {
                ret.push(model.get(c));
            }
            else {
                ret.push("");
            }
        });
        return ret;
    }

    /**
    * A simple module to replace `Backbone.sync` with *Database*-based persistence.
    * @name Backbone.DBStorage
    * @class [dbstorage] A Backbone.sync Adapter based on SQL.
    * @constructor
    */

    // Our Store is represented by a single JS object in *Database*. Create it
    // with a meaningful name, like the name you'd give a database.
    Backbone.DBStorage = function (name, key, columns) {
        this.name = name;
        this.dbkey = key;
        this.columns = columns;
    };

    Backbone.randomCID = guid;

    _.extend(Backbone.DBStorage.prototype, {

        sqlInsert: function (model, callback) {
            var cols = _(this.columns).map(function () {
                return "?";
            }).join(",");
            var request = "INSERT OR REPLACE INTO " +
                this.name +
                " (" + this.columns.join(",") +
                ") VALUES (" + cols + ")";
            var args = modelValues(this.columns, model);
            Database.exec(request, args, callback);
        },

        sqlUpdate: function (model, callback) {
            var dbkey = this.dbkey;
            var nonIdColumns = _(this.columns).filter(function (c) { return c != dbkey; });
            var sets = _(nonIdColumns).map(function (c) { return c + "=?"; });
            var request = "UPDATE " + this.name + " SET " + sets.join(",") + " WHERE " + dbkey + "='" + model.id + "'";
            var args = modelValues(nonIdColumns, model);
            Database.exec(request, args, callback);
        },

        sqlDelete: function (model, callback) {
            var dbkey = this.dbkey;
            var request = "DELETE FROM " + this.name + " WHERE " + dbkey + "='" + model.id + "'";
            Database.exec(request, [], callback);
        },

        sqlSelect: function (model, callback) {
            var dbkey = this.dbkey;
            var request = "SELECT * FROM " + this.name + " WHERE " + dbkey + "='" + model.id + "'";
            Database.exec(request, [], function (rows) {
                rows.forEach(function (m) { m.id = m[dbkey]; });
                if (typeof callback === "function") {
                    callback(rows);
                }
            });
        },

        sqlSelectAll: function (callback) {
            var dbkey = this.dbkey;
            var request = "SELECT * FROM " + this.name;
            Database.exec(request, [], function (rows) {
                rows.forEach(function (m) { m.id = m[dbkey]; });
                if (typeof callback === "function") {
                    callback(rows);
                }
            });
        },

        sqlSelectWhere: function (where, args, callback) {
            var dbkey = this.dbkey;
            var request = "SELECT * FROM " + this.name + " WHERE " + where;
            Database.exec(request, args, function (rows) {
                rows.forEach(function (m) { m.id = m[dbkey]; });
                if (typeof callback === "function") {
                    callback(rows);
                }
            });
        },

        // Save the current state of the **Store** to *localStorage*.
        // save: function() {
        // this.localStorage().setItem(this.name, this.records.join(","));
        // Database.save();
        // },

        // Add a model, giving it a (hopefully)-unique GUID, if it doesn't already
        // have an id of it's own.
        create: function (model, callback) {
            var that = this;
            if (!model.get(this.dbkey)) {
                if (model.id) {
                    model.set(this.dbkey, model.id);
                }
                else {
                    model.set(this.dbkey, guid());
                }
            }
            model.id = model.get(this.dbkey);
            that.sqlInsert(model, /* function() {
                that.find(model, callback);
            } */ callback);
        },

        // Update a model by replacing its copy in the database.
        update: function (model, callback) {
            var that = this;
            // Find the object
            this.find(model, function (rows) {
                if (rows.length === 0) { // New one? INSERT
                    that.sqlInsert(model, /* function() {
                        that.find(model, callback);
                    } */ callback);
                }
                else { // Existing one? UPDATE
                    that.sqlUpdate(model, /* function() {
                        that.find(model, callback);
                    } */ callback);
                }
            });
        },

        // Retrieve a model from database by id.
        find: function (model, callback) {
            this.sqlSelect(model, callback);
        },

        // Return the array of all models currently in the database.
        findAll: function (callback) {
            this.sqlSelectAll(callback);
        },

        // Delete a model from database, returning it.
        destroy: function (model, callback) {
            if (model.isNew()) {
                callback(false);
            }
            else {
                this.sqlDelete(model, function (/*rows*/) {
                    callback(model);
                });
            }
        }
    });

    Backbone.DBStorage.prepare = function (model) {
        // Add some SQLish sugar to collection.
        if (!model.whereSQL) {
            model.whereSQL = function (where, args, callback) {
                var store = model.dbStorage || model.collection.dbStorage;
                store.sqlSelectWhere(where, args, callback);
            };
        }
        if (model.collection) {
            model.collection.whereSQL = model.whereSQL;
        }
    };

    // Database sync delegate to the model or collection's
    // *localStorage* property, which should be an instance of `Store`.
    Backbone.DBStorage.sync = function (method, model, options) {
        var store = model.dbStorage || model.collection.dbStorage;
        var syncDfd = $.Deferred && $.Deferred(); //If $ is having Deferred - use it. 

        // Handle a successful response
        var handleResp = function (resp) {
            model.trigger("sync", model, resp, options);
            if (options && options.success) {
                if (Backbone.VERSION === "0.9.10") {
                    options.success(model, resp, options);
                } else {
                    options.success(resp);
                }
            }
            if (syncDfd) {
                syncDfd.resolve(resp);
            }
        };

        // Handle failure
        var handleError = function () {
            var errorMessage = "Record Not Found";
            model.trigger("error", model, errorMessage, options);
            if (options && options.error) {
                if (Backbone.VERSION === "0.9.10") {
                    options.error(model, errorMessage, options);
                } else {
                    options.error(errorMessage);
                }
            }
            if (syncDfd) {
                syncDfd.reject(errorMessage);
            }
        };

        // Handle response from the performed operation.
        var storeResponseCallback = function (resp) {
            if (resp) {
                handleResp(resp);
            } else {
                handleError();
            }

            // add compatibility with $.ajax
            // always execute callback for success and error
            if (options && options.complete) {
                options.complete(resp);
            }
        };

        try {
            switch (method) {
            case "read":
                // resp = model.id != undefined ? store.find(model) : store.findAll();
                if (model.id !== undefined) {
                    store.find(model, storeResponseCallback);
                } else {
                    store.findAll(storeResponseCallback);
                }
                break;
            case "create":
                store.create(model, storeResponseCallback);
                break;
            case "update":
                store.update(model, storeResponseCallback);
                break;
            case "delete":
                store.destroy(model, storeResponseCallback);
                break;
            }

        } catch (error) {
            // if (error.code === DOMException.QUOTA_EXCEEDED_ERR && window.localStorage.length === 0)
            //   errorMessage = "Private browsing is unsupported";
            // else
            //   errorMessage = error.message;
            if (options && options.error) {
                options.error(error.message);
            }
        }

        return syncDfd && syncDfd.promise();
    };

    Backbone.DBStorage.savedSync = Backbone.sync;
    Backbone.DBStorage.getSyncMethod = function (model) {
        if (model.dbStorage || (model.collection && model.collection.dbStorage)) {
            return Backbone.DBStorage.sync;
        }
        return Backbone.DBStorage.savedSync;
    };

    /** Override 'Backbone.sync' to default to Backbone.DBStorage.sync,
    * the original 'Backbone.sync' is still available in 'Backbone.DBStorage.ajaxSync' */
    Backbone.sync = function (method, model, options) {
        return Backbone.DBStorage.getSyncMethod(model).apply(this, [method, model, options]);
    };

    return Backbone.DBStorage;
});
