var View = require('./abstract'),
    _ = require('underscore'),
    Vuln = require('../models/vuln'),
    markdown = require('markdown').markdown,
    VulnTemplate = require('../../templates/vuln/vuln.html'),
    Pager = require('./pager');

module.exports = View.extend({

    el: '#main',
    template: _.template(VulnTemplate),

    include: ['vuln'],

    initialize: function(opts) {
        View.prototype.initialize.call(this, opts);
        if (!this.vuln) {
            this.vuln = new Vuln({
                id: this.vuln_id
            }, this.opts());
            this.vuln.fetch();
        }
        this.listenTo(this.vuln, 'sync change', this.renderIt);
    },

    context: function(ctx) {
        ctx = View.prototype.context.call(this, ctx);
        ctx.markdown = markdown;
        return ctx;
    },

    onStart: function() {
        this.render();
    },



});