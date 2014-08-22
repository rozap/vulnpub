var View = require('./abstract'),
    _ = require('underscore'),
    User = require('../models/user'),
    RegisterTemplate = require('../../templates/auth/register.html');

module.exports = View.extend({
    el: '#raw',
    template: _.template(RegisterTemplate),

    include: ['user'],

    events: {
        'click .register-button': 'register',
        'keyup': 'onKeyup'
    },

    onStart: function() {
        this.app.dispatcher.trigger('nav.hide');
        this.user = new User({}, this.opts());
        this.listenTo(this.user, 'sync error request invalid', this.renderIt);
        this.render();
    },

    register: function() {
        this.user.set(this.$el.find('form').serializeObject());
        console.log(this.user.toJSON());
        this.user.save();
    },

    onKeyup: function(e) {
        if (e.keyCode === 13) this.register();
    }


});