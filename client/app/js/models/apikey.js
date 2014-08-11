var Model = require('./abstract');

module.exports = Model.extend({
	api: function() {
		return 'apikey'
	},

	persist: function() {
		localStorage['vulnpub-apikey'] = JSON.stringify({
			username: this.get('username'),
			key: this.get('key')
		});
	}
});