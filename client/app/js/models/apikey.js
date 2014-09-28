var Model = require('./abstract');

module.exports = Model.extend({
	idAttribute: 'key',
	api: function() {
		return 'apikey';
	}
});