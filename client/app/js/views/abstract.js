var Backbone = require('backbone'),
    _ = require('underscore'),
    $ = require('jquery'),
    ErrorTemplate = require('../../templates/util/error.html');

module.exports = Backbone.View.extend({

    include: [],

    _errorTemplate: _.template(ErrorTemplate),

    initialize: function(opts) {
        _.extend(this, opts);
        this._views = {};
        if (!this.app) throw new Error('can u not');
    },


    render: function(ctx) {
        ctx = this.context(ctx);
        this.pre(ctx);
        this._render(ctx);
        _.each(this._views, function(view, name) {
            view.setElement(this.$el.find(view.el));
            view.render();
        }.bind(this));
        this.post(ctx);
    },

    _render: function(ctx) {
        this.$el.html(this.template(ctx));
    },

    listenTo: function(obj, evs, cb) {
        return evs.split(' ').map(function(name) {
            Backbone.View.prototype.listenTo.call(this, obj, name, cb);
        }.bind(this));
    },

    context: function(ctx) {
        ctx = ctx || {};

        var included = {};
        this.include.forEach(function(name) {
            included[name] = _.isFunction(this[name]) ? this[name].bind(this) : this[name]
        }.bind(this))

        return _.extend({
            _: _,
            showError: this._errors.bind(this)
        }, included, ctx);
    },


    _errors: function(name, model) {
        var errors = model.getErrors();
        if (errors) {
            errors = JSON.parse(errors.responseText)
            return this._errorTemplate({
                name: name,
                errors: errors
            });
        }
    },

    pre: function(ctx) {

    },

    post: function(ctx) {

    },

    onStart: function() {

    },

    opts: function(os) {
        return _.extend({
            app: this.app
        }, os);
    },

    renderIt: function() {
        this.render();
    },

    spawn: function(name, view) {
        this._views[name] && this._views[name].end();
        this._views[name] = view;
        view.onStart();
    },

    end: function() {
        _.each(this._views, function(v, name) {
            v.end();
        });
        this.undelegateEvents();
        this.stopListening();
        this.$el.html('');
        this.trigger('end', this);
        return this;
    }

});