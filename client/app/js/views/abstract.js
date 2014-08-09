var Backbone = require('backbone'),
	_ = require('underscore'),
	$ = require('jquery');

module.exports = Backbone.View.extend({

	include: [],

	initialize: function(opts) {
		_.extend(this, opts);
		if (!this.app) throw new Error('can u not');
	},


	render: function(ctx) {
		ctx = this.context(ctx);
		this.pre(ctx);
		this._render(ctx);
		this.post(ctx);
	},

	_render: function(ctx) {
		this.$el.html(this.template(ctx));
	},

	context: function(ctx) {
		ctx = ctx || {};

		var included = {};
		this.include.forEach(function(name) {
			included[name] = _.isFunction(this[name]) ? this[name].bind(this) : this[name]
		}.bind(this))

		return _.extend({
			_: _
		}, included, ctx);
	},

	pre: function(ctx) {

	},

	post: function(ctx) {

	},

	onStart: function() {

	},

	opts: function(os) {
		return _.extend({
			app: this.app
		}, os);
	}

});