var View = require('./abstract'),
	_ = require('underscore'),
	Monitors = require('../collections/monitors'),
	CreateMonitor = require('./create-monitor'),
	HomeTemplate = require('../../templates/home/home.html'),
	Pager = require('./pager');

module.exports = View.extend({

	el: '#main',
	template: _.template(HomeTemplate),

	include: ['monitors', 'greet'],

	events: {
		'click .new-monitor': 'create'
	},

	_greetings: ['hello', 'greetings', 'sup', 'what\'s happening'],


	initialize: function(opts) {
		View.prototype.initialize.call(this, opts);
		this.app.dispatcher.trigger('nav.show');
		this._greet = this._greetings[Math.floor(Math.random() * this._greetings.length)];

		this.monitors = new Monitors([], this.opts());
		this.listenTo(this.monitors, 'sync error add', this.renderIt);
		this.monitors.fetch();
	},

	onStart: function() {
		this.render();
	},

	onCreated: function(monitor) {
		this.monitors.add(monitor);
	},

	create: function() {
		var view = this.spawn('create', new CreateMonitor(this.opts()));
		this.listenTo(view, 'created', this.onCreated);
	},

	greet: function() {
		return this._greet + ' ' + this.app.auth.getUsername();
	}



});