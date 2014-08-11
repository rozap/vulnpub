var View = require('./abstract'),
    _ = require('underscore'),
    ApiKey = require('../models/apikey'),
    LoginTemplate = require('../../templates/auth/login.html');

module.exports = View.extend({
    el: '#raw',
    template: _.template(LoginTemplate),

    include: ['apikey'],

    events: {
        'click .login-button': 'login',
        'keyup': 'onKeyup'
    },

    onStart: function() {
        this.app.dispatcher.trigger('nav.hide');
        this.apikey = new ApiKey({}, this.opts());
        this.listenTo(this.apikey, 'sync error', this.renderIt);
        this.render();
    },

    redirect: function() {
        this.apikey.persist();
        this.app.router.navigate('#', {
            trigger: true
        });
    },

    login: function() {
        this.apikey.set(this.$el.find('form').serializeObject()).save().then(this.redirect.bind(this));
    },

    onKeyup: function(e) {
        if (e.keyCode === 13) this.login();
    }


});