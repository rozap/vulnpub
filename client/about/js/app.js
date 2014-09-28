console.log("about")
var $ = require('jquery'),
	_ = require('underscore'),
	JsonMarkup = require('json-markup'),
	Examples = require('./examples');

$(document).ready(function() {

	_.zip($('.manifest-example'), Examples).map(function(pair) {
		$(pair[0]).html(JsonMarkup(pair[1]));
	});
})