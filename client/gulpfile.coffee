gulp = require("gulp")

angularFilesort = require "gulp-angular-filesort"
coffee          = require "gulp-coffee"
concat          = require "gulp-concat"
connect         = require 'gulp-connect'
hamlc           = require "gulp-haml-coffee"
sass            = require 'gulp-sass'
history         = require 'connect-history-api-fallback'
inject          = require "gulp-inject"
karma           = require "gulp-karma"
mainBowerFiles  = require 'main-bower-files'
protractor      = require("gulp-protractor").protractor
rimraf          = require "gulp-rimraf"
templates       = require 'gulp-angular-templatecache'
uglify          = require "gulp-uglify"
merge           = require "merge-stream"
awspublish      = require('gulp-awspublish')
fs              = require "fs"
jshint          = require "gulp-jshint"
stylish         = require "jshint-stylish"
replace         = require "gulp-replace"
print           = require "gulp-print"
runSequence     = require "run-sequence"

handleError = (err) ->
  console.log err.toString()
  @emit "end"

# COMPILE
# ===========

gulp.task "compile", [
  "clean"
  "compile-fonts"
  "compile-images"
  "compile-styles"
  "compile-scripts"
  "compile-views"
  "compile-additional-files"
  ]

gulp.task "clean", ->
  # gulp.src(["./dist/**/*.*"],
  #   read: false
  # ).pipe rimraf()

gulp.task "compile-images", ->
  gulp.src("./app/images/**/*.*")
      .pipe gulp.dest("./dist/images")

gulp.task "compile-fonts", ->
  gulp.src("./app/fonts/**/*.*")
      .pipe gulp.dest("./dist/fonts")

gulp.task "compile-additional-files", ->
  gulp.src([
      "./app/robots.txt"
      "./app/apple-touch-icon.png"
      "./app/favicon.ico"
      "./app/404.html"
      ])
      .pipe gulp.dest("./dist")

gulp.task "compile-styles", ->
  gulp.src([
    # "./app/styles/*.scss"
    "./app/styles/boostrap.scss"
    "./app/styles/ui.scss"   # <- throws a stream error
    "./app/styles/main.scss"
    ])
      .pipe(sass({sourceComments: 'normal'}))
      .pipe gulp.dest("./dist/styles")

gulp.task "compile-scripts", ['lint'], ->
  coffeeFiles = gulp.src([
    "./app/scripts/**/*.coffee"
  ]).pipe(coffee(bare: true))

  jsFiles = gulp.src("./app/scripts/**/*.js")

  merge(coffeeFiles, jsFiles)
    .pipe(angularFilesort())
    .pipe(concat("reveltalent-client.js"))
    # .pipe(uglify())   # ENABLE: uglification
    .pipe gulp.dest("./dist/")

gulp.task "lint", ->
  gulp.src("./app/scripts/**/*.js")
    .pipe(jshint())
    .pipe jshint.reporter(stylish)

gulp.task "compile-views", ->
  gulp.src("./app/views/**/*.html")
      .pipe gulp.dest("./dist/views")

gulp.task "compile-views-to-js", ->  # Disabled for now, but it's fun to have all view in one js file.
  hamlFiles = gulp.src("./app/views/**/*.hamlc").pipe(hamlc())
  htmlFiles = gulp.src("./app/views/**/*.html")
  merge(hamlFiles, htmlFiles)
      .pipe(templates(standalone: false, root: '/', module: 'AdminWeb.views'))
      .pipe(concat("reveltalent-client-views.js"))
      .pipe(gulp.dest("./dist"))

gulp.task 'index.html', [ 'compile' ], ->
  target = gulp.src('app/index.html')
  bowerFiles = gulp.src(mainBowerFiles(), {read: false})
  angularFiles = gulp.src(['./dist/**/*.js'], {read: false}).pipe(angularFilesort())
  cssFiles = gulp.src(['./dist/styles/*.css'], {read: false})
  target.pipe(inject(bowerFiles, starttag: '<!-- inject:bower:{{ext}} -->', ignorePath: 'bower_components'))
        .pipe(inject(angularFiles, ignorePath: 'dist'))
        .pipe(inject(cssFiles, ignorePath: 'dist'))
        .pipe(gulp.dest('./dist'))
        .pipe(connect.reload())


# TEST
# ====

gulp.task "test", ["compile"], ->
  gulp.src("./test/spec/**.coffe").pipe(karma(   # FIXME: figure who the real source of specs to run is. karma.conf.coffee defines specs.
    configFile: "./test/karma.conf.coffee"
    action: "run"
  )).on "error", (err) ->
    # Make sure failed tests cause gulp to exit non-zero
    throw err

gulp.task "test:watch", ["compile"], ->
  gulp.src("./test/spec/**/*.js").pipe(karma(
    configFile: "./test/karma.conf.coffee"
    action: "watch"
  ))

gulp.task "protractor", ->
  gulp.src(["./test/e2e/**/scenarios.coffee"]).pipe(protractor(
    configFile: "test/protractor.conf.js"
    args: [
      "--baseUrl"
      "http://127.0.0.1:8000/"
    ]
  ))



# DEVELOPMENT
# ===========

gulp.task 'dev-server', ->
  connect.server
    root: [
      './dist'
      './bower_components'
      './vendors'
    ]
    port: 9000,
    livereload: true
    middleware: (connect, opt) ->
      [history, (->
        url     = require 'url'
        proxy   = require 'proxy-middleware'
        options = url.parse 'http://localhost:3000/api'
        options.route = '/rest/api'
        proxy options
      )()]

gulp.task 'watch', ->
  gulp.watch('app/index.html', ['index.html'])
  gulp.watch(['app/**/*.coffee', 'app/**/*.js','app/**/*.hamlc', 'app/**/*.html', 'app/**/*.css'], ['compile', 'index.html'])


gulp.task 'build',   ['index.html', 'watch']
gulp.task 'dev', ['dev-server', 'build']
gulp.task "default", ['test']

# DEPLOY TO S3
# ============

setupBaseUrl = (baseUrl) ->
  gulp.src(['./dist/reveltalent-client.js'])
      .pipe(replace('//local.reveltalent.com:3000', baseUrl))
      .pipe(gulp.dest('./dist/s3'))

deploy = (bucketName) ->
  aws = JSON.parse(fs.readFileSync("./config/aws.json"))
  aws.bucket = bucketName
  headers =
    "Cache-Control": "max-age=315360000, no-transform, public"

  console.log("[Copying to #{aws.bucket} ]")
  publisher = awspublish.create(aws);
  gulp.src("./dist/s3/**/*.*")
    .pipe(publisher.publish(headers))
    .pipe(publisher.sync())
    .pipe(awspublish.reporter())

gulp.task "prepare_bower_dist", ->
  gulp.src(mainBowerFiles(), { base: 'bower_components' })
    .pipe(gulp.dest("./dist/s3"))

gulp.task "prepare_appfiles_dist", ->
  gulp.src(["!./dist/s3", "!./dist/s3/**/*.*", "./dist/**/*.*"])
    .pipe(gulp.dest("./dist/s3"))

gulp.task "baseurl", ->
  setupBaseUrl "https://api.reveltalent.com"

gulp.task "copys3", ->
  deploy "reveltalent"

gulp.task "copys3:production", ->
  deploy "reveltalent.com"



gulp.task "deploy", ->
  runSequence("index.html",
              "prepare_bower_dist",
              "prepare_appfiles_dist",
              "baseurl",
              "copys3")
