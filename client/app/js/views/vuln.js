var View = require('./abstract'),
	_ = require('underscore'),
	Vulns = require('../collections/vulns'),
	VulnTemplate = require('../../templates/vuln/vuln.html');

module.exports = View.extend({

	el: '#main',
	template: _.template(VulnTemplate),

	include: ['vulns'],

	initialize: function(opts) {
		View.prototype.initialize.call(this, opts);
		this.vulns = new Vulns([], this.opts());
		this.listenTo(this.vulns, 'sync', this.renderIt);
		this.vulns.fetch();
	},

	onStart: function() {
		this.render();
	}


});