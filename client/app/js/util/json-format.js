var $ = require('jquery'),
    _ = require('underscore'),
    JsonMarkup = require('json-markup');


module.exports = {
    format: function(examples) {
        _.zip($('.manifest-example'), examples).map(function(pair) {
            $(pair[0]).html(JsonMarkup(pair[1]));
        });

        ///hack to get the keys stringified
        $('.json-markup-key').each(function(i, el) {
            var $el = $(el),
                str = '"' + $el.text().split(':')[0] + '":';
            $el.text(str);
        })
    }
};