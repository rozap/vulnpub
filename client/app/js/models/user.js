var Model = require('./abstract');

module.exports = Model.extend({
    api: function() {
        return 'users'
    },

    validate: function(attrs, options) {
        if (attrs.password !== attrs.confirm_password) {
            console.log(attrs.password, attrs.confirm_password)
            return {
                password: "Your passwords don't match"
            };
        }
    }

});