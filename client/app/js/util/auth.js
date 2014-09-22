var name = 'vulnpub-apikey';

var Auth = function(app) {
	this.app = app;
	this.app.dispatcher.on('auth.authenticated', this._onAuthenticated.bind(this));
};


Auth.prototype = {

	authenticate: function() {
		console.log("authenticating...");
		var ApiKey = require('../models/apikey');
		var key = new ApiKey(JSON.parse(localStorage[name]), {
			app: this.app
		});
		return key.fetch().then(this._onLoggedIn.bind(this), this._onLoginFail.bind(this));
	},

	_onAuthenticated: function(apikey) {
		localStorage[name] = JSON.stringify({
			username: apikey.get('username'),
			key: apikey.get('key')
		});
		this._onLoggedIn();
		console.log("On authed")
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
			};
		} catch (e) {
			console.warn('cannot parse localstorage ;_;', localStorage[name]);
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