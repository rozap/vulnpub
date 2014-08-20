var Collection = require('./abstract');


module.exports = Collection.extend({

    _currentOrder: 'created',

    api: function() {
        return 'vulns';
    }


});