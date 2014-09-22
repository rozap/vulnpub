var Backbone = require('backbone'),
	Auth = require('./auth');


module.exports = {

	isLoading: function() {
		return !!this._isRequesting;
	},

	onStart: function() {
		this.listenTo(this, 'request', this._onRequest);
		this.listenTo(this, 'sync', this._onSync);
		this.listenTo(this, 'error', this._onError);
	},

	_onSync: function() {
		this._hasSynced = true;
		this._isRequesting = false;
		this._hasErrored = false;
		this._lastError = null;

	},

	_onRequest: function() {
		this._hasSynced = false;
		this._isRequesting = true;
		this._hasErrored = false;
		this._lastError = null;
	},

	_onError: function(model, resp, opts) {
		this._hasSynced = false;
		this._isRequesting = false;
		this._hasErrored = true;
		try {
			console.log("error", resp.responseText)
			this._lastError = JSON.parse(resp.responseText);
		} catch (e) {
			this._lastError = true;
		}
	},


	getErrors: function() {
		if (this._lastError) return this._lastError;
		if (this.validationError) return {
			errors: this.validationError
		};
	},


	sync: function() {
		var args = Array.prototype.slice.call(arguments);
		opts = arguments[2] || {};
		opts.headers = this.app.auth.headers();
		args[2] = opts;
		return Backbone.sync.apply(this, args);
	}
};