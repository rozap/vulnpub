var View = require('./abstract'),
    _ = require('underscore'),
    Monitor = require('../models/monitor'),
    Template = require('../../templates/monitor/monitor.html'),
    Pager = require('./pager');

module.exports = View.extend({

    el: '#main',
    template: _.template(Template),

    include: ['monitor'],

    initialize: function(opts) {
        View.prototype.initialize.call(this, opts);
        this.app.dispatcher.trigger('nav.show');

        this.monitor = new Monitor({
            id: this.monitor_id
        }, this.opts());
        this.listenTo(this.monitor, 'sync', this.renderIt);
        this.monitor.fetch();
    },

    onStart: function() {
        this.render();
    },



});