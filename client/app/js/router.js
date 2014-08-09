var Backbone = require('backbone'),
	_ = require('underscore'),
	VulnView = require('./views/vuln')


;
module.exports = Backbone.Router.extend({

	routes: {
		'vulns': 'vulns',

	},

	initialize: function() {
		this.app = {
			router: this,
			dispatcher: _.clone(Backbone.Events)
		};
	},

	_create: function(View) {
		if (this.view) this.view.end();
		this.view = new View({
			app: this.app
		});
		this.app.dispatcher.trigger('module', this.view);
		this.view.onStart();
	},

	vulns: function() {
		this._create(VulnView);
	}


});