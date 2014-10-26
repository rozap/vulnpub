var Model = require('./abstract');

module.exports = Model.extend({
    idAttribute: 'key',
    api: function() {
        return 'reset';
    },

    validate: function(attrs, options) {
        if (this.isNew()) return;
        if (attrs.password !== attrs.confirm_password) {
            return {
                password: "Your passwords don't match"
            };
        }
    }

});