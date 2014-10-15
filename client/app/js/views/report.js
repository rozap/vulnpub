var View = require('./abstract'),
    _ = require('underscore'),
    PackageCollection = require('../collections/packages'),
    Vuln = require('../models/vuln'),
    VulnView = require('./vuln'),
    ReportTemplate = require('../../templates/vuln/report.html'),
    SearchViewTemplate = require('../../templates/vuln/search-packages.html'),
    EffectsViewTemplate = require('../../templates/vuln/effect.html');



var SearchView = View.extend({

    el: '#search-view',
    include: ['packageSearch', 'currentIndex', 'sliceSize', 'sliceOffset'],
    template: _.template(SearchViewTemplate),

    currentIndex: 0,
    sliceOffset: 0,
    sliceSize: 8,

    events: {
        'mousewheel': 'onWheel',
        'click .select-package': 'onClickPackage'
    },

    onStart: function(parent) {
        this.packageSearch = new PackageCollection([], this.opts());
        this.listenTo(this.packageSearch, 'sync', this.renderIt);
        this.listenTo(parent, 'keyup', this.keyUp);
        this.listenTo(parent, 'keydown', this.keyDown);
    },

    keyDown: function(e) {
        if (e.keyCode === 40) {
            this.onDown();
        } else if (e.keyCode === 38) {
            this.onUp();
        }
    },

    keyUp: function(e) {
        if (e.keyCode === 13) {
            this.select();
        } else {
            this.typeahead($(e.currentTarget).val());
        }
    },

    typeahead: function(value) {
        if (this.packageSearch.setFilter('name', value)) {
            this.reset();
            this.packageSearch.fetch();
        }
    },

    onDown: function() {
        if (this.currentIndex < this.packageSearch.length - this.sliceSize) {
            this.set('currentIndex', this.currentIndex + 1);
        } else if ((this.currentIndex + this.sliceOffset) < this.packageSearch.length - 1) {
            this.set('sliceOffset', this.sliceOffset + 1);
        }
    },

    reset: function() {
        this.currentIndex = 0;
        this.sliceOffset = 0;
    },

    onUp: function() {
        if (this.sliceOffset > 0) {
            this.set('sliceOffset', this.sliceOffset - 1);
        } else if (this.currentIndex > 0) {
            this.set('currentIndex', this.currentIndex - 1);
        }
    },

    select: function() {
        this.trigger('select', this.packageSearch.at(this.currentIndex + this.sliceOffset));
        this.reset();
    },

    onClickPackage: function(e) {
        var id = parseInt($(e.currentTarget).data('package'));
        this.trigger('select', this.packageSearch.get(id));
        this.reset();
    },

    onWheel: function(e) {
        (e.originalEvent.wheelDelta > 0 ? this.onUp : this.onDown).call(this);
    }

});


var EffectsView = View.extend({
    el: '#add-vuln-effect',
    template: _.template(EffectsViewTemplate),
    events: {
        'keydown #effects_package': 'keydown',
        'keyup #effects_package': 'keyup',
    },

    include: ['vuln'],

});


module.exports = View.extend({

    el: '#main',
    template: _.template(ReportTemplate),

    include: ['vuln'],

    events: {
        'keyup input': 'update',
        'keyup textarea': 'update',
        'click .add-effected': 'addEffected',
        'click .add-patched': 'addPatched',
        'click .save': 'save'
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
        this.addSearch();
    },


    _createEffectsView: function(vulnerable) {
        if (this.hasView('effects')) this.endView('effects');
        this.spawn('effects', new EffectsView(this.opts({
            vulnerable: vulnerable,
            vuln: this.vuln
        })));
        this.render();
    },

    addEffected: function() {
        this._createEffectsView(true);
    },

    addPatched: function() {
        this._createEffectsView(false);
    },

    addSearch: function() {
        var search = this.spawn('search', new SearchView(this.opts()));
        this.listenTo(search, 'select', this.onSelected);
    },

    update: function() {
        return this.vuln.set(this.$el.find('form').serializeObject());
    },

    keydown: function(e) {
        this.trigger('keydown', e);
    },

    keyup: function(e) {
        if (!this.hasView('search')) this.addSearch();
        this.trigger('keyup', e);
    },

    onSelected: function(pack) {
        this.vuln.set('effects_package', pack.get('name'));
        this.endView('search');
        this.render();
        this.$el.find('input[name="effects_version]').focus();
    },

    save: function() {
        this.update().save();
    }

});