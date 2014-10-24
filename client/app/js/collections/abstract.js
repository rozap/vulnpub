var Backbone = require('backbone'),
    _ = require('underscore'),
    DataMixin = require('../util/data-layer-mixin');

module.exports = Backbone.Collection.extend({


    initialize: function(models, opts) {
        this.app = opts.app;
        this._filter = {};
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
        opts.data = opts.data || this._getUrlParams();
        return Backbone.Collection.prototype.fetch.call(this, opts);
    },

    _getUrlParams: function() {
        var opts = {
            page: this.getPage(),
            order: this._currentOrder
        };
        if (this._filter.name && this._filter.value) opts.filter = this._getFilters();
        return opts;
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
    },

    _getFilters: function() {
        return this._filter.name + ':' + this._filter.value;
    },

    getFilters: function() {
        return this._filter;
    },

    setFilter: function(name, value) {
        var ogName = this._filter.name;
        var ogVal = this._filter.value;
        this._filter.name = name;
        this._filter.value = value;
        return this._filter.name !== ogName || this._filter.value !== ogVal;
    },

    _prepareModel: function(attrs, options) {
        if (attrs instanceof Backbone.Model) return attrs;
        options = options ? _.clone(options) : {};
        options.app = this.app;
        options.collection = this;
        var model = new this.model(attrs, options);
        if (!model.validationError) return model;
        this.trigger('invalid', this, model.validationError, options);
        return false;
    },



});