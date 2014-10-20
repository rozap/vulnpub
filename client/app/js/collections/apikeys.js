var Collection = require('./abstract'),
    Apikey = require('../models/apikey');


module.exports = Collection.extend({
    model: Apikey,
    api: function() {
        return 'apikey';
    },
});