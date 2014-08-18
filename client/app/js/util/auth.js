var name = 'vulnpub-apikey';

module.exports = {
	headers: function() {
		try {
			var key = JSON.parse(localStorage[name]);
			return {
				'authentication': key.username + ':' + key.key
			}
		} catch (e) {

		}
	},


	logout: function() {
		localStorage[name] = null;
	},

	getUsername: function() {
		return JSON.parse(localStorage[name]).username;
	}
};