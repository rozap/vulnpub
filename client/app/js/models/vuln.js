var Model = require('./abstract');


module.exports = Model.extend({
	api: function() {
		return 'vulns';
	}
});