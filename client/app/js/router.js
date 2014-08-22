var Backbone = require('backbone'),
    _ = require('underscore'),
    VulnList = require('./views/vuln-list'),
    Vuln = require('./views/vuln'),
    Monitor = require('./views/monitor'),
    Login = require('./views/login'),
    Register = require('./views/register'),
    SideNav = require('./views/side-nav'),
    Home = require('./views/home'),
    Landing = require('./views/landing'),
    Report = require('./views/report'),
    Auth = require('./util/auth'),
    CreateMonitor = require('./views/create-monitor');



module.exports = Backbone.Router.extend({

    views: {
        'landing': Landing,
        'home home': Home,
        'vuln-list vulns': VulnList,
        'vuln vulns/:vuln_id': Vuln,
        'monitor monitors/:monitor_id': Monitor,
        'login login': Login,
        'register register': Register,
        'report report': Report
    },

    initialize: function() {
        this.app = {
            router: this,
            dispatcher: _.clone(Backbone.Events),
            auth: Auth
        };

        _.each(this.views, function(Klass, descriptor) {
            var nameRoute = descriptor.split(' '),
                name = nameRoute[0],
                route = nameRoute[1] || '';
            this.route(route, name, _.partial(this._create, Klass, route).bind(this));
        }, this);

        this.nav = new SideNav({
            app: this.app
        });
        this.nav.onStart();
    },

    _create: function() {
        var args = Array.prototype.slice.call(arguments);
        var View = args[0],
            route = args[1];

        var opts = {
            app: this.app
        };
        console.log(route)
        if (this.view) this.view.end();
        this.view = new View(opts);
        this.app.dispatcher.trigger('module', this.view);
        this.view.onStart();
    },



});