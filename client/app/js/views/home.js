var View = require('./abstract'),
    _ = require('underscore'),
    Monitors = require('../collections/monitors'),
    Alerts = require('../collections/alerts'),
    CreateMonitor = require('./create-monitor'),
    HomeTemplate = require('../../templates/home/home.html'),
    MonitorTemplate = require('../../templates/home/monitor.html'),

    Pager = require('./pager');


var MonitorView = View.extend({
    tagName: 'div',
    attributes: {
        'class': 'pure-u-1-2 monitor-card-wrap'
    },
    template: _.template(MonitorTemplate),
    include: ['model', 'askConfirm'],

    events: {
        'click .remove-monitor': 'remove',
        'click .confirm-remove': 'confirmRemove',
        'click .dont-remove': 'dontRemove'

    },

    confirmRemove: function() {
        this.model.destroy();
    },

    remove: function() {
        this.set('askConfirm', true);
    },

    dontRemove: function() {
        this.set('askConfirm', false);
    }
});


module.exports = View.extend({

    el: '#main',
    template: _.template(HomeTemplate),

    include: ['monitors', 'greet', 'alerts'],

    events: {
        'click .new-monitor': 'create',
        'click .dismiss-alert': 'dismiss',
        'click .alert-item-inner': 'gotoVuln',
    },

    _views: [],

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
            })));
        }
        this._endMonitors();
        var $ms = this.$el.find('.monitor-list');
        this.monitors.each(function(monitor) {
            var view = new MonitorView(this.opts({
                model: monitor
            }));
            this._views.push(view);
            $ms.append(view.render().el);
        }.bind(this));
    },

    _endMonitors: function() {
        _.invoke(this._views, 'end');
        this._views = [];
    },

    onCreated: function(monitor) {
        this.monitors.add(monitor);
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
        });
        al.save().then(this.alerts.fetch.bind(this.alerts));
        e.preventDefault();
    },

    end: function() {
        this._endMonitors();
        View.prototype.end.call(this);
    }



});