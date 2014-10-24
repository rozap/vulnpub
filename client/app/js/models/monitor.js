var Model = require('./abstract'),
    Collection = require('../collections/abstract');


module.exports = Model.extend({

    initialize: function(attrs, opts) {
        Model.prototype.initialize.apply(this, Array.prototype.slice.call(arguments));
        var c = new Collection([], opts);
        ['getFilters'].map(function(name) {
            this[name] = c[name].bind(this);
        }.bind(this));
    },

    api: function() {
        return 'monitors';
    }
});