var View = require('./abstract'),
    _ = require('underscore'),
    OmniSearch = require('./omni-search'),
    TopNavTemplate = require('../../templates/util/top-nav.html');

module.exports = View.extend({
    el: '.header',
    template: _.template(TopNavTemplate),

    events: {
        'click': 'home'
    },

    onStart: function() {
        if(this.app.dispatcher) this.listenTo(this.app.dispatcher, 'auth.change', this.render);
        this.spawn('omni', new OmniSearch(this.opts()));
        this.render();
    }
});