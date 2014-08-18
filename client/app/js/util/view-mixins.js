var _ = require('underscore');

var templates = {
	'loader': require('../../templates/util/loader.html')
};

module.exports = {
	inject: function(name, ctx) {
		return _.template(templates[name])(ctx);
	}
};