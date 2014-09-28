var View = require('./abstract'),
    _ = require('underscore'),
    SettingsTemplate = require('../../templates/settings/settings.html'),
    User = require('../models/user');


module.exports = View.extend({

    el: '#main',
    template: _.template(SettingsTemplate),

    include: ['user'],

    events: {
        'click .save': 'save'
    },

    initialize: function(opts) {
        View.prototype.initialize.call(this, opts);
        this.user = new User(this.app.auth.getUser(), this.opts());
        console.log(this.user.toJSON());
        this.listenTo(this.user, 'sync error request', this.renderIt);
        this.user.fetch();
        this.app.dispatcher.trigger('nav.show');
    },

    onStart: function() {
        this.render();
    },

    save: function() {
        this.user.set(this.$el.find('form').serializeObject()).save();
    }

});