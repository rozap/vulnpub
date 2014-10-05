var gulp = require('gulp'),
    less = require('gulp-less'),
    uglify = require('gulp-uglify'),
    spawn = require('child_process').spawn,
    minifyCSS = require('gulp-minify-css'),
    browserify = require('browserify'),
    source = require('vinyl-source-stream'),
    sourcemaps = require('gulp-sourcemaps'),
    stringify = require('stringify'),
    buffer = require('vinyl-buffer');

var paths = {
    js: {
        app: {
            src: './app/js/app.js',
            dest: '../priv/static/js/',
            watch: ['./app/**/*.js', './app/*.js', './app/**/*.html']
        },
        about: {
            src: './about/js/app.js',
            dest: '../priv/static/js/',
            watch: ['./about/**/*.js', './about/*.js']
        },

        server: {
            watch: ['./**/*.js', '!./assets/**/*.js']
        }
    },

    less: {
        src: './assets/less/style.less',
        dest: '../priv/static/style/',
        watch: ['./assets/less/*.less'],
    }
};

var bundles = ['about', 'app'];


var create = function(src, name, dst) {
    var bundleStream = browserify(src);
    bundleStream.transform(stringify(['.html']));
    bundleStream.bundle()
        .pipe(source(name))
        .pipe(buffer())
        .pipe(sourcemaps.init({
            loadMaps: true
        }))
        .pipe(uglify())
        .pipe(sourcemaps.write('maps'))
        .pipe(gulp.dest(dst));
};


bundles.forEach(function(name) {
    gulp.task(name, function() {
        console.log("building", name);
        create(paths.js[name].src, name + '.js', paths.js[name].dest);
    });
});

gulp.task('less', function() {
    console.log("Rebuilding less files...");
    gulp.src(paths.less.src)
        .pipe(less({
            paths: ['style.less']
        }))
        .pipe(minifyCSS())
        .pipe(gulp.dest(paths.less.dest));
});


gulp.task('watch', function() {
    bundles.forEach(function(name) {
        gulp.watch(paths.js[name].watch, [name]);
    });

    gulp.watch(paths.less.watch, ['less']);
});


gulp.task('default', bundles.concat(['watch']));
gulp.task('deploy', bundles.concat(['less']));