var _ = require('underscore'),
    Model = require('../models/log');

var levels = ['log', 'info', 'warn', 'error'];

var Logger = function(app) {
    this.app = app;
    this.repeated = 0;
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
        var newLine = args.map(function(a) {
            return a ? a.toString() : a;
        });
        if (_.difference(newLine, _.last(this._cache)).length === 0) {
            this.repeated += 1;
        } else {
            this._cache.push(newLine);
            this._addRepeat();
        }
        og.apply(console, args.slice(1));
    },

    _addRepeat: function() {
        if (this.repeated > 0) {
            _.last(this._cache).push("[Repeated " + this.repeated + " times]");
            this.repeated = 0;
        }
    },

    _flush: function() {
        if (this._cache.length === 0) return;
        this._addRepeat();
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