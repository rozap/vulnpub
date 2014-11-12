console.log("about");
var $ = require('jquery'),
	_ = require('underscore'),
	Backbone = require('backbone'),
	Examples = require('./examples'),
	Formatter = require('../../app/js/util/json-format'),
	Nav = require('../../app/js/views/top-nav'),
	Auth = require('../../app/js/util/auth');

Backbone.$ = $;

$(document).ready(function() {
	var app = {
		dispatcher: _.clone(Backbone.Events),

	};
	app.auth = new Auth(app);
	var nav = new Nav({
		app: app
	});

	nav.onStart();
	Formatter.format(Examples);
});