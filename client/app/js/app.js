console.log('beep boop');

var Router = require('./router'),
	$ = require('jquery');
var Backbone = require('backbone');
Backbone.$ = $;


/////just for debugging
window.$ = $;

$(document).ready(function() {
	var router = new Router();
	Backbone.history.start();
})