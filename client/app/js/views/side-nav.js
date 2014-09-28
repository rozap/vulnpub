var View = require('./abstract'),
    _ = require('underscore'),
    SideNavTemplate = require('../../templates/util/side-nav.html');

module.exports = View.extend({
    el: '#side-nav',
    template: _.template(SideNavTemplate),

    onStart: function() {
        this.listenTo(this.app.dispatcher, 'nav.hide', this.hide);
        this.listenTo(this.app.dispatcher, 'nav.show', this.show);
        this.render();
    },

    hide: function() {
        $('#main').hide();
        $('#raw').show();
        this.$el.hide();
    },

    show: function() {
        this.render();
        $('#main').show();
        $('#raw').hide();
        this.$el.show();
    }
})