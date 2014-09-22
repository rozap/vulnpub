var Backbone = require('backbone'),
    _ = require('underscore'),
    VulnList = require('./views/vuln-list'),
    Vuln = require('./views/vuln'),
    Monitor = require('./views/monitor'),
    Login = require('./views/login'),
    Logout = require('./views/logout'),
    Register = require('./views/register'),
    SideNav = require('./views/side-nav'),
    Home = require('./views/home'),
    Landing = require('./views/landing'),
    Report = require('./views/report'),
    Auth = require('./util/auth'),
    CreateMonitor = require('./views/create-monitor');



module.exports = Backbone.Router.extend({

    views: {
        //access name route
        'private home': Home,
        'public landing landing': Landing,
        'public vuln-list vulns': VulnList,
        'public vuln vulns/:vuln_id': Vuln,
        'private monitor monitors/:monitor_id': Monitor,
        'public login login': Login,
        'public logout logout': Logout,
        'public register register': Register,
        'private report report': Report
    },

    initialize: function() {
        this.app = {
            router: this,
            dispatcher: _.clone(Backbone.Events),
        };
        this.app.auth = new Auth(this.app);

        this.nav = new SideNav({
            app: this.app
        });
        this.nav.onStart();

        this.app.auth.authenticate()
            .always(this._setupRoutes.bind(this));
    },

    _setupRoutes: function() {
        _.each(this.views, function(Klass, descriptor) {
            var nameRoute = descriptor.split(' '),
                access = nameRoute[0],
                name = nameRoute[1],
                route = nameRoute[2] || '';
            this.route(route, name, _.partial(this._create, Klass, route, access).bind(this));
        }, this);
        Backbone.history.start();
    },

    landing: function() {
        return this.navigate('#landing', {
            trigger: true,
            replace: true
        });
    },

    _create: function() {
        var args = Array.prototype.slice.call(arguments);
        var View = args[0],
            route = args[1],
            access = args[2],
            params = /:\w+/gi.exec(route),
            routeParams = params && params.map(function(n) {
                return n.slice(1);
            });

        if (access === 'private' && !this.app.auth.isLoggedIn()) {
            this.landing();
            return;
        }

        var opts = _.extend({
            app: this.app
        }, _.object(routeParams, _.compact(args.slice(3))));

        console.log("create view with", opts);
        if (this.view) this.view.end();
        this.view = new View(opts);
        this.app.dispatcher.trigger('module', this.view);
        this.view.onStart();
    },



});