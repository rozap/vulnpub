console.log('beep boop');

var Router = require('./router'),
	$ = require('jquery');

$.fn.serializeObject = function() {
	var obj = {};

	$.each(this.serializeArray(), function(i, o) {
		var n = o.name,
			v = o.value;

		obj[n] = obj[n] === undefined ? v : $.isArray(obj[n]) ? obj[n].concat(v) : [obj[n], v];
	});

	return obj;
};

var Backbone = require('backbone');
Backbone.$ = $;



/////just for debugging
window.$ = $;

$(document).ready(function() {

	var router = new Router();
	Backbone.history.start();
})