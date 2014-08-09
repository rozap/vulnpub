var Backbone = require('backbone'),
	_ = require('underscore');


module.exports = Backbone.Collection.extend({

	initialize: function(models, opts) {
		this.app = opts.app;
		if (!this.app) throw new Error("supply an app to the collection pls");
	},

	url: function() {
		return '/api/v1/' + this.api();
	},

	parse: function(resp) {
		this.meta = resp.meta;
		return resp.data;
	}


});