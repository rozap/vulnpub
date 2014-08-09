var gulp = require('gulp'),
    less = require('gulp-less'),
    uglify = require('gulp-uglify'),
    spawn = require('child_process').spawn,
    minifyCSS = require('gulp-minify-css'),
    browserify = require('browserify'),
    source = require('vinyl-source-stream'),
    stringify = require('stringify'),
    node;

var paths = {
    js: {
        client: {
            src: './app/js/app.js',
            dest: '../priv/static/js/',
            watch: ['./app/**/*.js', './app/*.js', './app/**/*.html']
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


process.on('exit', function() {
    if (node) node.kill()
})



gulp.task('browserify', function() {
    console.log("browserifying....")
    var bundleStream = browserify(paths.js.client.src);
    bundleStream.transform(stringify(['.html']))
    bundleStream.bundle()
        .pipe(source('app.js'))
    // .pipe(uglify())
    .pipe(gulp.dest(paths.js.client.dest));
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
    gulp.watch(paths.js.client.watch, ['browserify']);
    gulp.watch(paths.less.watch, ['less']);
});



gulp.task('default', ['watch', 'browserify'])