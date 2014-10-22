var View = require('./abstract'),
    _ = require('underscore'),
    SettingsTemplate = require('../../templates/settings/settings.html'),
    User = require('../models/user'),
    Apikeys = require('../collections/apikeys');
Apikey = require('../models/apikey');


module.exports = View.extend({

    el: '#main',
    template: _.template(SettingsTemplate),

    include: ['user', 'apikeys', 'newKey', 'isSaving'],

    events: {
        'click .save': 'save',
        'click .revoke': 'revoke',
        'click .create-key': 'createKey'
    },

    initialize: function(opts) {
        View.prototype.initialize.call(this, opts);
        this.user = new User(this.app.auth.getUser(), this.opts());
        this.apikeys = new Apikeys([], this.opts());
        this.newKey = new Apikey({}, this.opts());
        this.listenTo(this.user, 'sync error request invalid', this.renderIt);
        this.listenTo(this.apikeys, 'sync error, request remove', this.renderIt);
        this.listenTo(this.newKey, 'sync', this.onNewKey);
        this.listenTo(this.newKey, 'error', this.renderIt);
        this.user.fetch();
        this.fetch();
        this.app.dispatcher.trigger('nav.show');
    },

    fetch: function() {
        this.apikeys.fetch({
            data: {
                'filter': 'web:false'
            }
        });
    },

    post: function() {
        console.log(this.user.getErrors())
    },

    onStart: function() {
        this.render();
    },

    save: function() {
        this.isSaving = true;
        this.user
            .set(this.$el.find('.user-form').serializeObject())
            .save();
    },

    revoke: function(e) {
        var id = $(e.currentTarget).data('id');
        this.apikeys.get(id).destroy();
    },

    createKey: function() {
        this.newKey
            .set(this.$el.find('.apikey-form').serializeObject())
            .set({
                web: false
            })
            .save();
    },

    onNewKey: function() {
        this.newKey.clear();
        this.fetch();
    }

});