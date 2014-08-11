var View = require('./abstract'),
	_ = require('underscore'),
	Monitors = require('../collections/monitors'),
	CreateMonitor = require('./create-monitor'),
	HomeTemplate = require('../../templates/home/home.html'),
	Pager = require('./pager');

module.exports = View.extend({

	el: '#main',
	template: _.template(HomeTemplate),

	include: ['monitors'],

	events: {
		'click .new-monitor': 'create'
	},


	initialize: function(opts) {
		View.prototype.initialize.call(this, opts);
		this.app.dispatcher.trigger('nav.show');

		this.monitors = new Monitors([], this.opts());
		this.listenTo(this.monitors, 'sync error add', this.renderIt);
		this.monitors.fetch();
	},

	onStart: function() {
		this.render();
	},

	onCreated:function(monitor) {
		this.monitors.add(monitor);
	},

	create: function() {
		var view = this.spawn('create', new CreateMonitor(this.opts()));
		this.listenTo(view, 'created', this.onCreated);
	}



});