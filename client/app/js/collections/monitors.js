var Collection = require('./abstract'),
    Monitor = require('../models/monitor');


module.exports = Collection.extend({
    model: Monitor,
    api: function() {
        return 'monitors';
    },


});