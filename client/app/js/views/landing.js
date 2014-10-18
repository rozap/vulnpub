var View = require('./abstract'),
	_ = require('underscore'),
	Formatter = require('../util/json-format'),
	Examples = require('../../../about/js/examples'),
	LandingTemplate = require('../../templates/home/landing.html');

module.exports = View.extend({

	el: '#raw',
	template: _.template(LandingTemplate),

	initialize: function(opts) {
		View.prototype.initialize.call(this, opts);
		this.app.dispatcher.trigger('nav.hide');
		this.render();
	},

	post: function() {
		console.log(Examples[3])
		Formatter.format([Examples[3]]);
	}



});