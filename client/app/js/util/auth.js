var _ = require('underscore');

var name = 'vulnpub-apikey';

var Auth = function(app) {
    this.app = app;
    this.app.dispatcher.on('auth.authenticated', this._onAuthenticated.bind(this));
};


Auth.prototype = {

    authenticate: function() {
        var ApiKey = require('../models/apikey');
        try {
            var key = new ApiKey(JSON.parse(localStorage[name]), {
                app: this.app
            });
            return key.fetch().then(this._onLoggedIn.bind(this), this._onLoginFail.bind(this));
        } catch (e) {
            //pass
        }
        return (new $.Deferred()).reject();

    },

    _onAuthenticated: function(apikey) {
        localStorage[name] = JSON.stringify({
            username: apikey.get('username'),
            key: apikey.get('key'),
            id: apikey.get('user_id')
        });
        this._onLoggedIn();
    },

    _onLoginFail: function() {
        this._isLoggedIn = false;
        this.app.dispatcher.trigger('auth.change', this._isLoggedIn);
    },

    _onLoggedIn: function() {
        this._isLoggedIn = true;
        this.app.dispatcher.trigger('auth.change', this._isLoggedIn);
    },

    _onLoggedOut: function() {
        this._isLoggedIn = false;
        this.app.dispatcher.trigger('auth.change', this._isLoggedIn);
    },

    hasAttempted: function() {
        return !_.isUndefined(this._isLoggedIn);
    },

    headers: function() {
        try {
            var key = JSON.parse(localStorage[name]);
            return {
                'authentication': key.username + ':' + key.key
            };
        } catch (e) {
            if (localStorage[name] && localStorage[name].length) {
                console.info('cannot parse localstorage');
            }
        }
    },

    logout: function() {
        localStorage[name] = null;
        this._onLoggedOut();
    },

    getUsername: function() {
        return this.getUser().username;
    },

    getUser: function() {
        return JSON.parse(localStorage[name]);
    },

    isLoggedIn: function() {
        return !!this._isLoggedIn;
    }
};


module.exports = Auth;