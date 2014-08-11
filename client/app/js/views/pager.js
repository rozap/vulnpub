var View = require('./abstract'),
    _ = require('underscore'),
    PagerTemplate = require('../../templates/util/pager.html');

module.exports = View.extend({

    template: _.template(PagerTemplate),

    include: ['fib', 'collection'],

    events: {
        'click .to-page': 'goToPage'
    },


    onStart: function() {
        this.render();
    },

    fib: function() {
        var i;
        var arr = [];
        arr[0] = 0;

        arr[1] = 1;
        for (i = 2; i <= 18; i++) {
            arr[i] = arr[i - 2] + arr[i - 1];
        }
        return arr.filter(function(i) {
            return i < this.collection.pageCount();
        }.bind(this));
    },


    goToPage: function(e) {
        var page = $(e.currentTarget).data('page');
        this.collection.setPage(parseInt(page)).fetch();

    }



});