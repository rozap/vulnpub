var View = require('./abstract'),
    _ = require('underscore'),
    Vulns = require('../collections/vulns'),
    VulnTemplate = require('../../templates/vuln/vuln-list.html'),
    Pager = require('./pager');

module.exports = View.extend({

    el: '#main',
    template: _.template(VulnTemplate),

    include: ['vulns', 'shorten'],

    initialize: function(opts) {
        View.prototype.initialize.call(this, opts);
        this.vulns = new Vulns([], this.opts());
        this.listenTo(this.vulns, 'sync', this.renderIt);
        this.vulns.fetch();
    },

    onStart: function() {
        this.render();
    },

    post: function() {
        if (this.vulns.pageCount() > 0) {
            this.spawn('pager', new Pager(this.opts({
                el: this.$el.find('#vuln-pager').selector,
                collection: this.vulns
            })));
        }
    },

    shorten: function(str, to) {
        to = to || 20;
        if (str.length > to) {
            return str.slice(0, to - 3) + '...';
        }
        return str;
    }


});