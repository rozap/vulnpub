console.log("about");
var $ = require('jquery'),
	Examples = require('./examples'),
	Formatter = require('../../app/js/util/json-format');

$(document).ready(function() {
	Formatter.format(Examples);
});