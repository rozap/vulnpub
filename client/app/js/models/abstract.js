var Backbone = require('backbone'),
    _ = require('underscore'),
    DataMixin = require('../util/data-layer-mixin');


module.exports = Backbone.Model.extend({

    initialize: function(attrs, opts) {
        Backbone.Model.prototype.initialize.call(this, attrs, opts);
        this.app = opts.app;
        if (!this.app) throw new Error("supply an app to the model pls");

        _.extend(this, DataMixin);
        this.onStart();
    },

    url: function() {
        return '/api/v1/' + this.api() + (this.get('id') ? '/' + this.get('id') : '');
    },


});