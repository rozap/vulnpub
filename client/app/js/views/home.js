var View = require('./abstract'),
    _ = require('underscore'),
    Monitors = require('../collections/monitors'),
    Alerts = require('../collections/alerts'),
    CreateMonitor = require('./create-monitor'),
    HomeTemplate = require('../../templates/home/home.html'),
    Pager = require('./pager');

module.exports = View.extend({

    el: '#main',
    template: _.template(HomeTemplate),

    include: ['monitors', 'greet', 'alerts'],

    events: {
        'click .new-monitor': 'create',
        'click .dismiss-alert': 'dismiss',
        'click .alert-item-inner': 'gotoVuln',
        'click .remove-monitor': 'removeMonitor'
    },

    _greetings: ['hello', 'greetings', 'sup', 'what\'s happening', 'how goes it'],


    initialize: function(opts) {
        View.prototype.initialize.call(this, opts);
        this.app.dispatcher.trigger('nav.show');
        this._greet = this._greetings[Math.floor(Math.random() * this._greetings.length)];

        this.alerts = new Alerts([], this.opts());
        this.monitors = new Monitors([], this.opts());
        this.listenTo(this.alerts, 'sync error remove', this.renderIt);
        this.listenTo(this.monitors, 'sync error add remove', this.renderIt);
        this.alerts.fetch();
        this.monitors.fetch();
    },

    onStart: function() {
        this.render();
    },

    post: function() {
        if (this.alerts.pageCount() > 0) {
            this.spawn('alert_pager', new Pager(this.opts({
                el: this.$el.find('#alert-pager').selector,
                collection: this.alerts
            })))
        }
    },

    onCreated: function(monitor) {
        this.monitors.add(monitor);
    },

    removeMonitor: function(e) {
        var id = $(e.currentTarget).data('id');
        this.monitors.get(id).destroy();
    },

    create: function() {
        var view = this.spawn('create', new CreateMonitor(this.opts()));
        this.listenTo(view, 'created', this.onCreated);
    },

    greet: function() {
        return this._greet + ' ' + this.app.auth.getUsername();
    },

    gotoVuln: function(e) {
        if (e.isDefaultPrevented()) return;
        var url = 'vulns/' + $(e.currentTarget).data('vuln');
        this.app.router.navigate(url, {
            trigger: true
        });
    },

    dismiss: function(e) {
        var al = this.alerts.get(parseInt($(e.currentTarget).data('alert')));
        al.set({
            'acknowledged': true
        })
        al.save().then(this.alerts.fetch.bind(this.alerts));
        e.preventDefault();
    }



});