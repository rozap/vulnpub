var View = require('./abstract'),
    _ = require('underscore'),
    Monitor = require('../models/monitor'),
    Collection = require('../collections/abstract'),
    Template = require('../../templates/monitor/monitor.html'),
    Pager = require('./pager');

module.exports = View.extend({

    el: '#main',
    template: _.template(Template),

    include: ['monitor', 'proxy'],

    initialize: function(opts) {
        View.prototype.initialize.call(this, opts);
        this.app.dispatcher.trigger('nav.show');
        this._setupProxy();
        this.monitor = new Monitor({
            id: this.monitor_id
        }, this.opts());
        this.listenTo(this.monitor, 'sync', this.loadProxy);
        this.listenTo(this.monitor, 'sync', this.renderIt);
        this.fetch();
    },

    fetch: function() {
        this.monitor.fetch({
            data: this.proxy._getUrlParams()
        });
    },

    onStart: function() {
        this.app.dispatcher.trigger('views.omni.search', this, {
            collection: this.proxy,
            name: 'packages',
            searchOn: 'package.name'
        });
        this.render();
    },

    loadProxy: function() {
        this.proxy.set(this.monitor.get('packages').data);
        this.proxy.meta = this.monitor.get('packages').meta;
    },

    post: function() {
        var packages = this.monitor.get('packages');
        if (this.proxy.pageCount()) {
            this.spawn('pager', new Pager(this.opts({
                el: this.$el.find('#package-pager').selector,
                collection: this.proxy
            })));
        }
    },

    _setupProxy: function() {
        this.proxy = new Collection([], this.opts());
        this.proxy.fetch = this.fetch.bind(this);
    }


});