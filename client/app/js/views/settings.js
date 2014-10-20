var View = require('./abstract'),
    _ = require('underscore'),
    SettingsTemplate = require('../../templates/settings/settings.html'),
    User = require('../models/user'),
    Apikeys = require('../collections/apikeys');


module.exports = View.extend({

    el: '#main',
    template: _.template(SettingsTemplate),

    include: ['user', 'apikeys'],

    events: {
        'click .save': 'save',
        'click .revoke': 'revoke'
    },

    initialize: function(opts) {
        View.prototype.initialize.call(this, opts);
        this.user = new User(this.app.auth.getUser(), this.opts());
        this.apikeys = new Apikeys([], this.opts());
        this.listenTo(this.user, 'sync error request', this.renderIt);
        this.listenTo(this.apikeys, 'sync error, request remove', this.renderIt);
        this.user.fetch();
        this.apikeys.fetch({
            data: {
                'filter:web': false
            }
        });
        this.app.dispatcher.trigger('nav.show');
    },

    onStart: function() {
        this.render();
    },

    save: function() {
        this.user.set(this.$el.find('form').serializeObject()).save();
    },

    revoke: function(e) {
        var id = $(e.currentTarget).data('id');
        this.apikeys.get(id).destroy();
    }

});