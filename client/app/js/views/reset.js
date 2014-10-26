var View = require('./abstract'),
    _ = require('underscore'),
    ResetPass = require('../models/reset'),
    ResetTemplate = require('../../templates/auth/reset.html');

module.exports = View.extend({
    el: '#raw',
    template: _.template(ResetTemplate),

    include: ['reset'],

    events: {
        'click .reset-button': 'sendReset',
        'keyup': 'onKeyup'
    },

    onStart: function() {
        this.app.dispatcher.trigger('nav.hide');
        this.reset = new ResetPass({
            key: this.key
        }, this.opts());
        this.listenTo(this.reset, 'sync error invalid', this.renderIt);
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