var Backbone = require('backbone'),
	_ = require('underscore'),
	$ = require('jquery');

module.exports = Backbone.View.extend({

	include: [],

	initialize: function(opts) {
		_.extend(this, opts);
		this._views = {};
		if (!this.app) throw new Error('can u not');
	},


	render: function(ctx) {
		ctx = this.context(ctx);
		this.pre(ctx);
		this._render(ctx);
		_.each(this._views, function(view, name) {
			view.setElement(this.$el.find(view.el));
			view.render();
		}.bind(this));
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
	},

	renderIt: function() {
		this.render();
	},

	spawn: function(name, view) {
		this._views[name] && this._views[name].end();
		this._views[name] = view;
		view.onStart();
	},

	end: function() {
		_.each(this._views, function(v, name) {
			v.end();
		});
		this.undelegateEvents();
		this.stopListening();
		this.$el.html('');
		this.trigger('end', this);
		return this;
	}

});