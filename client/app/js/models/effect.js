var _ = require('underscore'),
    Model = require('./abstract');


module.exports = Model.extend({

    validateVersion: function() {
        return !!/^(~>|>|<|>=|<=|==) ?(\d+\.\d+\.\d+)$/.exec(this.get('version'))
    },


    validate: function() {
        var errors = {};
        if (!this.validateVersion()) {
            var v = this.get('version') || '';
            _.extend(errors, {
                version: '"' + v + '" is not a valid version'
            });

        }

        if (!this.get('name')) {
            _.extend(errors, {
                name: 'You need to include a name'
            });
        }
        if (_.keys(errors).length) return errors;
    }


});