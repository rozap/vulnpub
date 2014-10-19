var View = require('./abstract'),
	_ = require('underscore'),
	OmniSearch = require('./omni-search'),
	TopNavTemplate = require('../../templates/util/top-nav.html');

module.exports = View.extend({
	el: '.header',
	template: _.template(TopNavTemplate),

	events: {
		'click': 'home',
		'click a': 'nope'
	},

	onStart: function() {
		this.listenTo(this.app.dispatcher, 'auth.change', this.render);
		this.spawn('omni', new OmniSearch(this.opts()))
		this.render();
	},

	nope: function(e) {
		e.awfulHack = true;
	},

	home: function(e) {
		if (e.awfulHack) return;
		this.app.router.navigate('#', {
			trigger: true
		});
	}

})