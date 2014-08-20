var Collection = require('./abstract'),
	Alert = require('../models/alert');


module.exports = Collection.extend({

	_currentOrder: 'created',
	model: Alert,

	api: function() {
		return 'alerts';
	}


});