console.log('beep boop');

var Router = require('./router'),
	$ = require('jquery'),
	moment = require('moment');

$.fn.serializeObject = function() {
	var obj = {};

	$.each(this.serializeArray(), function(i, o) {
		var n = o.name,
			v = o.value;

		obj[n] = obj[n] === undefined ? v : $.isArray(obj[n]) ? obj[n].concat(v) : [obj[n], v];
	});

	return obj;
};

$(document).ready(function() {
	$('input').keydown(function(event) {
		if (event.keyCode == 13) {
			event.preventDefault();
			return false;
		}
	});
});

var Backbone = require('backbone');
Backbone.$ = $;



/////just for debugging
window.$ = $;

$(document).ready(function() {
	var router = new Router();
})