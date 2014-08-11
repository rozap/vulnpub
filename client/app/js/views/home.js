var View = require('./abstract'),
	_ = require('underscore'),
	Monitors = require('../collections/monitors'),
	HomeTemplate = require('../../templates/home/home.html'),
	Pager = require('./pager');

module.exports = View.extend({

	el: '#main',
	template: _.template(HomeTemplate),

	include: ['monitors'],


	initialize: function(opts) {
		View.prototype.initialize.call(this, opts);
		this.monitors = new Monitors([], this.opts());
		this.listenTo(this.monitors, 'sync error', this.renderIt);
		this.monitors.fetch();
	},

	onStart: function() {
		this.render();
	},



});