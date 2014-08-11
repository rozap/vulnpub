var Backbone = require('backbone'),
    _ = require('underscore'),
    DataMixin = require('../util/data-layer-mixin');

module.exports = Backbone.Collection.extend({

    initialize: function(models, opts) {
        this.app = opts.app;
        if (!this.app) throw new Error("supply an app to the collection pls");

        _.extend(this, DataMixin);
        this.onStart();
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

    nextPage: function() {
        if (this.getPage() >= this.pageCount()) return false;
        return this.setPage(this.getPage() + 1);
    },

    prevPage: function() {
        if (this.getPage() <= 0) return false;
        return this.setPage(this.getPage() - 1);
    }



});