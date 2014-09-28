var View = require('./abstract'),
    _ = require('underscore'),
    TopNavTemplate = require('../../templates/util/top-nav.html');

module.exports = View.extend({
    el: '.header',
    template: _.template(TopNavTemplate),

    onStart: function() {
        this.listenTo(this.app.dispatcher, 'auth.change', this.render);
        this.render();
    }

})