var View = require('./abstract'),
    _ = require('underscore'),
    PagerTemplate = require('../../templates/util/omni-search.html');

module.exports = View.extend({
    el: '#omni-search',
    template: _.template(PagerTemplate),
    name: '',
    include: ['name', 'getFilterText'],
    attributes: {
        'class': 'filter-view'
    },

    events: {
        'keyup input.filter': 'onFilter'
    },


    onStart: function() {
        this.listenTo(this.app.dispatcher, 'views.omni.search', this.search);
        this.listenTo(this.app.dispatcher, 'views.omni.filter', this.filter);
    },

    shouldRender: function() {
        return !!this._showing;
    },

    search: function(owner, options) {
        this._showing = true;
        this.listenToOnce(owner, 'end', this.hide);
        _.extend(this, options);
        this.render();
    },

    hide: function() {
        this._showing = false;
        this.$el.html('');
    },

    onFilter: function(e) {
        var val = $(e.currentTarget).val();
        if (this.collection.setFilter(this.searchOn, val)) {
            this.collection.setPage(0);
            this.collection.fetch();
        }
    },

    getFilterText: function() {
        return this.collection ? this.collection.getFilters().value : '';
    }


});