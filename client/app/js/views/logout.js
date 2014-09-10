var View = require('./abstract'),
    _ = require('underscore'),
    LoginTemplate = require('../../templates/auth/logout.html'),
    Auth = require('../util/auth');

module.exports = View.extend({
    el: '#raw',
    template: _.template(LoginTemplate),

    include: ['apikey'],

    events: {
        'click .login-button': 'login',
        'keyup': 'onKeyup'
    },

    include: ['link'],
    links: [{
        name: 'enjoy some light reading',
        url: 'http://en.wikipedia.org/wiki/Wikipedia:Featured_articles'
    }, {
        name: 'learn something new',
        url: 'https://www.khanacademy.org/'
    }, {
        name: 'dance',
        url: 'http://8tracks.com/'
    }, {
        name: 'contribute to open source',
        url: 'https://github.com/explore'
    }, {
        name: 'make some friends',
        url: 'https://chat.meatspac.es/'
    }],

    onStart: function() {
        this.app.dispatcher.trigger('nav.hide');
        this.app.auth.logout();
        this.link = _.sample(this.links);
        this.render();
    }

});