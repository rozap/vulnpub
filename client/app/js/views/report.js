var View = require('./abstract'),
    _ = require('underscore'),
    PackageCollection = require('../collections/packages'),
    Vuln = require('../models/vuln'),
    VulnView = require('./vuln'),
    ReportTemplate = require('../../templates/vuln/report.html'),
    SearchViewTemplate = require('../../templates/vuln/search-packages.html');



var SearchView = View.extend({

    el: '#search-view',
    include: ['packageSearch', 'currentIndex'],
    template: _.template(SearchViewTemplate),

    currentIndex: 0,


    onStart: function(parent) {
        this.packageSearch = new PackageCollection([], this.opts());
        this.listenTo(this.packageSearch, 'sync', this.renderIt);
        this.listenTo(parent, 'keyup', this.dispatchKey);
    },

    dispatchKey: function(e) {
        if (e.keyCode === 40) {
            this.onDown();
        } else if (e.keyCode === 38) {
            this.onUp();
        } else if (e.keyCode == 13) {

        } else {
            this.typeahead($(e.currentTarget).val());
        }
    },

    typeahead: function(value) {
        if (this.packageSearch.setFilter('name', value)) {
            this.packageSearch.fetch();
        }
    },

    onDown: function() {
        if (this.currentIndex < this.packageSearch.length) {
            this.set('currentIndex', this.currentIndex + 1);
        }
    },

    onUp: function() {
        if (this.currentIndex > 0) {
            this.set('currentIndex', this.currentIndex - 1);
        }
    }

});


module.exports = View.extend({

    el: '#main',
    template: _.template(ReportTemplate),

    include: ['vuln'],

    events: {
        'keyup input': 'update',
        'keyup textarea': 'update',
        'keyup #effects_package': 'typeahead'
    },

    initialize: function(opts) {
        View.prototype.initialize.call(this, opts);
        this.app.dispatcher.trigger('nav.show');
        this.vuln = new Vuln({}, this.opts());
        this.listenTo(this.vuln, 'sync error', this.renderIt);
    },

    onStart: function() {
        this.render();
        this.spawn('preview', new VulnView(this.opts({
            vuln: this.vuln,
            el: '#report-preview'
        })));
        this.spawn('search', new SearchView(this.opts()));
    },

    update: function() {
        this.vuln.set(this.$el.find('form').serializeObject());
    },

    typeahead: function(e) {
        this.trigger('keyup', e);
    }

});