var Model = require('./abstract');

module.exports = Model.extend({
	idAttribute: 'key',
	api: function() {
		return 'apikey' + (this.isNew() ? '' : '/' + this.get('key'));
	},

	persist: function() {
		localStorage['vulnpub-apikey'] = JSON.stringify({
			username: this.get('username'),
			key: this.get('key')
		});
	}
});