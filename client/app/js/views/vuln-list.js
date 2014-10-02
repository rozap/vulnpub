var View = require('./abstract'),
    _ = require('underscore'),
    Vulns = require('../collections/vulns'),
    VulnTemplate = require('../../templates/vuln/vuln-list.html'),
    Pager = require('./pager');

module.exports = View.extend({

    el: '#main',
    template: _.template(VulnTemplate),

    include: ['vulns', 'shorten'],

    events: {
        'mousewheel': 'onMouseWheel'
    },

    initialize: function(opts) {
        View.prototype.initialize.call(this, opts);
        this.app.dispatcher.trigger('nav.show');
        this.vulns = new Vulns([], this.opts());
        this.listenTo(this.vulns, 'sync', this.renderIt);
        this.vulns.fetch();
    },

    onStart: function() {
        this.app.dispatcher.trigger('views.omni.search', this, {
            collection: this.vulns,
            name: 'vulnerabilities',
            searchOn: 'name'
        })
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

    onMouseWheel: function(e) {
        if (e.originalEvent.wheelDelta < 0 ? this.vulns.nextPage() : this.vulns.prevPage()) {
            this.fetch();
            this.render();
        }
    },

    fetch: _.debounce(function() {
        this.vulns.fetch();
    }, 300),


    shorten: function(str, to) {
        to = to || 20;
        if (str.length > to) {
            return str.slice(0, to - 3) + '...';
        }
        return str;
    }


});