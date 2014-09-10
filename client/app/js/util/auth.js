var name = 'vulnpub-apikey';

var Auth = function(app) {
	this.app = app;
}


Auth.prototype = {

	authenticate: function() {
		console.log("authenticating...");
		var ApiKey = require('../models/apikey');
		var key = new ApiKey(JSON.parse(localStorage[name]), {
			app: this.app
		});
		return key.fetch().then(this._onLoggedIn.bind(this), this._onLoginFail.bind(this));
	},

	_onLoginFail: function() {
		this._isLoggedIn = false;
	},

	_onLoggedIn: function() {
		this._isLoggedIn = true;
	},

	headers: function() {
		try {
			var key = JSON.parse(localStorage[name]);
			return {
				'authentication': key.username + ':' + key.key
			}
		} catch (e) {
			console.warn('cannot parse localstorage ;_;')
		}
	},

	logout: function() {
		localStorage[name] = null;
	},

	getUsername: function() {
		return JSON.parse(localStorage[name]).username;
	},

	isLoggedIn: function() {
		return !!this._isLoggedIn;
	}
};


module.exports = Auth;