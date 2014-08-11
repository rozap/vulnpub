var Backbone = require('backbone'),
	_ = require('underscore'),
	VulnList = require('./views/vuln-list'),
	Vuln = require('./views/vuln'),
	Monitor = require('./views/monitor'),
	Login = require('./views/login'),
	SideNav = require('./views/side-nav'),
	Home = require('./views/home'),
	CreateMonitor = require('./views/create-monitor');


;
module.exports = Backbone.Router.extend({

	routes: {
		'': 'home',
		'vulns': 'vulns',
		'vulns/:id': 'vuln',
		'monitors/:id': 'monitor',
		'login': 'login',
		'create': 'create'
	},

	initialize: function() {
		this.app = {
			router: this,
			dispatcher: _.clone(Backbone.Events)
		};

		this.nav = new SideNav({
			app: this.app
		});
		this.nav.onStart();
	},

	_create: function(View, opts) {
		if (this.view) this.view.end();
		this.view = new View(_.extend({
			app: this.app
		}, opts));
		this.app.dispatcher.trigger('module', this.view);
		this.view.onStart();
	},

	home: function() {
		this._create(Home);
	},

	vulns: function() {
		this._create(VulnList);
	},

	vuln: function(id) {
		this._create(Vuln, {
			vuln_id: parseInt(id)
		});
	},

	login: function() {
		this._create(Login);
	},

	monitor: function(id) {
		this._create(Monitor, {
			monitor_id: parseInt(id)
		});
	}



});