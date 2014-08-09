var View = require('./abstract'),
    _ = require('underscore'),
    Vuln = require('../models/vuln'),
    VulnTemplate = require('../../templates/vuln/vuln.html'),
    Pager = require('./pager');

module.exports = View.extend({

    el: '#main',
    template: _.template(VulnTemplate),

    include: ['vuln'],

    initialize: function(opts) {
        View.prototype.initialize.call(this, opts);
        this.vuln = new Vuln({
            id: this.vuln_id
        }, this.opts());
        this.listenTo(this.vuln, 'sync', this.renderIt);
        this.vuln.fetch();
    },

    onStart: function() {
        this.render();
    },



});