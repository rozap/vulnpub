var _ = require('underscore'),
    Model = require('../models/log');

var levels = ['log', 'info', 'warn', 'error'];

var Logger = function(app) {
    this.app = app;
    this._cache = [];
    levels.map(function(lvl) {
        var og = console[lvl];
        console[lvl] = _.partial(this._proxyLevel, og, lvl).bind(this);
    }.bind(this));
    setInterval(this._flush.bind(this), 10000);
};


Logger.prototype = {

    _proxyLevel: function(og, lvl) {
        args = Array.prototype.slice.call(arguments, 1);
        this._cache.push(args.map(function(a) {
            return a.toString();
        }))
        og.apply(console, args.slice(1));
    },

    _flush: function() {
        var model = new Model({
            logs: this._cache
        }, {
            app: this.app
        });
        model.save().then(this._clearCache.bind(this), this._insertError.bind(this));
    },

    _clearCache: function() {
        this._cache = [];
    },

    _insertError: function() {
        console.error("Failed to save logs ;_;");
    }
};

module.exports = Logger;