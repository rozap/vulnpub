var Backbone = require('backbone'),
    _ = require('underscore');


module.exports = Backbone.Model.extend({

    initialize: function(models, opts) {
        this.app = opts.app;
        if (!this.app) throw new Error("supply an app to the model pls");
    },

    url: function() {
        return '/api/v1/' + this.api() + (this.get('id') ? '/' + this.get('id') : '');
    }


});