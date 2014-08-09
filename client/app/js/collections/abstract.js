var Backbone = require('backbone'),
    _ = require('underscore');


module.exports = Backbone.Collection.extend({

    initialize: function(models, opts) {
        this.app = opts.app;
        if (!this.app) throw new Error("supply an app to the collection pls");
        this.listenTo(this, 'request', this._onRequest);
        this.listenTo(this, 'sync', this._onSync);
        this.listenTo(this, 'error', this._onError);

    },

    url: function() {
        return '/api/v1/' + this.api();
    },

    parse: function(resp) {
        this.meta = resp.meta;
        return resp.data;
    },

    pageCount: function() {
        return this.meta ? this.meta.pages : 0;
    },

    fetch: function(opts) {
        opts = opts || {};
        opts.data = opts.data || {
            page: this.getPage()
        };
        return Backbone.Collection.prototype.fetch.call(this, opts);
    },

    setPage: function(p) {
        this._page = p;
        return this;
    },

    getPage: function() {
        return this._page || 0;
    },

    isLoading: function() {
        return !!this._isRequesting;
    },

    _onSync: function() {
        this._hasSynced = true;
        this._isRequesting = false;
        this._hasErrored = false;

    },

    _onRequest: function() {
        this._hasSynced = false;
        this._isRequesting = true;
        this._hasErrored = false;
    },

    _onError: function() {
        this._hasSynced = false;
        this._isRequesting = false;
        this._hasErrored = true;
    }



});