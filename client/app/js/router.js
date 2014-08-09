var Backbone = require('backbone'),
	_ = require('underscore'),
	VulnList = require('./views/vuln-list'),
	Vuln = require('./views/vuln');


;
module.exports = Backbone.Router.extend({

	routes: {
		'vulns': 'vulns',
		'vulns/:id': 'vuln',

	},

	initialize: function() {
		this.app = {
			router: this,
			dispatcher: _.clone(Backbone.Events)
		};
	},

	_create: function(View, opts) {
		if (this.view) this.view.end();
		this.view = new View(_.extend({
			app: this.app
		}, opts));
		this.app.dispatcher.trigger('module', this.view);
		this.view.onStart();
	},

	vulns: function() {
		this._create(VulnList);
	},

	vuln: function(id) {
		this._create(Vuln, {
			vuln_id: parseInt(id)
		});
	}



});