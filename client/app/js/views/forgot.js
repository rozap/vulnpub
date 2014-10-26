var View = require('./abstract'),
    _ = require('underscore'),
    ResetPass = require('../models/reset'),
    ForgotTemplate = require('../../templates/auth/forgot.html');

module.exports = View.extend({
    el: '#raw',
    template: _.template(ForgotTemplate),

    include: ['reset'],

    events: {
        'click .reset-button': 'sendReset',
        'keyup': 'onKeyup'
    },

    onStart: function() {
        this.app.dispatcher.trigger('nav.hide');
        this.reset = new ResetPass({}, this.opts());
        this.listenTo(this.reset, 'sync error', this.renderIt);
        this.render();
    },

    sendReset: function() {
        this.reset
            .set(this.$el.find('form').serializeObject())
            .save();
    },

    onKeyup: function(e) {
        if (e.keyCode === 13) this.sendReset();
    }


});