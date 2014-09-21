var View = require('./abstract'),
    _ = require('underscore'),
    Monitor = require('../models/monitor'),
    CreateTemplate = require('../../templates/home/create.html');

module.exports = View.extend({

    el: '#create-monitor',
    template: _.template(CreateTemplate),

    include: ['monitor'],

    events: {
        'click .save': 'save',
        'click .cancel': 'end',
    },


    initialize: function(opts) {
        View.prototype.initialize.call(this, opts);
        this.app.dispatcher.trigger('nav.show');
        this.monitor = new Monitor({}, this.opts());
        this.listenTo(this.monitor, 'sync error', this.renderIt);
    },

    onStart: function() {
        this.render();
    },

    onCreate: function() {
        this.trigger('created', this.monitor);
    },

    save: function() {
        this.monitor
            .set(this.$el.find('form').serializeObject())
            .save()
            .then(this.onCreate.bind(this));
    },



});