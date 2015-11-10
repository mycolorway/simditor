pkg               = require './package.json'
gulp              = require 'gulp'
gutil             = require 'gulp-util'
sass              = require 'gulp-sass'
coffee            = require 'gulp-coffee'
concat            = require 'gulp-concat'
umd               = require 'gulp-umd'
header            = require 'gulp-header'
moment            = require 'moment'
server            = require 'gulp-webserver'
cache             = require 'gulp-cached'
jasmine           = require 'gulp-jasmine-phantom'
child             = require 'child_process'
download          = require 'gulp-download'
rename            = require 'gulp-rename'
uglify            = require 'gulp-uglify'
ignore            = require 'gulp-ignore'
zip               = require 'gulp-zip'
del               = require 'del'
# debug             = require 'gulp-debug'


banner = '''
/*!
* Simditor v<%= pkg.version %>
* http://simditor.tower.im/
* <%= date %>
*/\n
'''

coffeeSourceFiles = [
  'src/selection.coffee'
  'src/formatter.coffee'
  'src/inputManager.coffee'
  'src/keystroke.coffee'
  'src/undoManager.coffee'
  'src/util.coffee'
  'src/toolbar.coffee'
  'src/indentation.coffee'
  'src/clipboard.coffee'
  'src/core.coffee'
  'src/i18n.coffee'
  'src/buttons/button.coffee'
  'src/buttons/popover.coffee'
  'src/buttons/title.coffee'
  'src/buttons/font-scale.coffee'
  'src/buttons/bold.coffee'
  'src/buttons/italic.coffee'
  'src/buttons/underline.coffee'
  'src/buttons/color.coffee'
  'src/buttons/list.coffee'
  'src/buttons/blockquote.coffee'
  'src/buttons/code.coffee'
  'src/buttons/link.coffee'
  'src/buttons/image.coffee'
  'src/buttons/indent.coffee'
  'src/buttons/outdent.coffee'
  'src/buttons/hr.coffee'
  'src/buttons/table.coffee'
  'src/buttons/strikethrough.coffee'
  'src/buttons/alignment.coffee'
]

gulp.task 'default', ['dev']

gulp.task 'dev', ['site'], ->
  gulp.src '_site'
    .pipe(server
      livereload: true
      open: true
    )

  gulp.watch 'styles/*.scss', ['sass:simditor', 'jekyll']
  gulp.watch 'site/assets/_sass/*.scss', ['sass:site', 'jekyll']
  gulp.watch ['src/*.coffee', 'src/buttons/*.coffee'], ['coffee:simditor', 'jekyll']
  gulp.watch 'site/assets/_coffee/*.coffee', ['coffee:site', 'jekyll']
  gulp.watch ['site/**/*.html', 'site/**/*.md', 'site/**/*.yml'], ['jekyll']
  gulp.watch 'spec/src/**/*.coffee', ['coffee:spec']

gulp.task 'test', ['coffee:spec'], ->
  gulp.src 'spec/**/*.js'
    .pipe jasmine({
      integration: true
      includeStackTrace: true
      vendor: [
        'vendor/bower/jquery/dist/jquery.min.js'
        'vendor/bower/simple-module/lib/module.js'
        'vendor/bower/simple-uploader/lib/uploader.js'
        'vendor/bower/simple-hotkeys/lib/hotkeys.js'
        'lib/simditor.js'
      ]
    })

gulp.task 'package', ['package:compress']

gulp.task 'package:assets', ['package:scripts', 'package:styles', 'package:images']

gulp.task 'package:scripts', ['package:clean'], ->
  gulp.src [
    'vendor/bower/jquery/dist/jquery.min.js'
    'vendor/bower/simple-module/lib/module.js'
    'vendor/bower/simple-uploader/lib/uploader.js'
    'vendor/bower/simple-hotkeys/lib/hotkeys.js'
    'lib/*.js'
  ]
    .pipe gulp.dest('package/scripts/')
    .pipe ignore.exclude('*.min.js')
    .pipe uglify({preserveComments: 'license'}).on('error', gutil.log)
    .pipe rename({suffix: '.min'})
    .pipe gulp.dest('package/scripts/')

gulp.task 'package:styles', ['package:clean'], ->
  gulp.src 'styles/*'
    .pipe gulp.dest('package/styles/')

gulp.task 'package:images', ['package:clean'], ->
  gulp.src 'site/assets/images/image.png'
    .pipe gulp.dest('package/images/')

gulp.task 'package:compress', ['package:assets'], ->
  gulp.src 'package/**/*.*'
    # .pipe debug({title: 'unicorn:'})
    .pipe zip("simditor-#{ pkg.version }.zip")
    .pipe gulp.dest('package/')

gulp.task 'fonticons', ->
  download 'http://use.fonticons.com/kits/d7611efe/d7611efe.css'
    .pipe rename('fonticon.scss')
    .pipe gulp.dest('styles/')

############################################
# all of below are components tasks
############################################

gulp.task 'package:clean', ->
  del(['package/*']).then (paths) ->
    gutil.log 'Deleted files/folders:\n', paths.join('\n')

gulp.task 'sass:simditor', ->
  gulp.src('styles/simditor.scss')
    .pipe sass(outputStyle: 'expanded').on('error', sass.logError)
    .pipe header(banner, { pkg : pkg, date: moment().format('YYYY-MM-DD') })
    .pipe gulp.dest('styles')
    .pipe gulp.dest('site/assets/styles/')

gulp.task 'sass:site', ->
  gulp.src(['site/assets/_sass/app.scss', 'site/assets/_sass/mobile.scss'])
    .pipe cache('sass:site')
    .pipe sass(outputStyle: 'expanded').on('error', sass.logError)
    .pipe gulp.dest('site/assets/styles')

gulp.task 'coffee:simditor', ->
  gulp.src coffeeSourceFiles
    .pipe concat('simditor.coffee')
    .pipe coffee(bare: true).on('error', gutil.log)
    .pipe umd({
      dependencies: (file) ->
        return [{
          name: '$'
          amd: 'jquery'
          cjs: 'jquery'
          global: 'jQuery'
          param: '$'
        }, {
          name: 'SimpleModule'
          amd: 'simple-module'
          cjs: 'simple-module'
          global: 'SimpleModule'
          param: 'SimpleModule'
        }, {
          name: 'simpleHotkeys'
          amd: 'simple-hotkeys'
          cjs: 'simple-hotkeys'
          global: 'simple.hotkeys'
          param: 'simpleHotkeys'
        }, {
          name: 'simpleUploader'
          amd: 'simple-uploader'
          cjs: 'simple-uploader'
          global: 'simple.uploader'
          param: 'simpleUploader'
        }]
    })
    .pipe header(banner, { pkg : pkg, date: moment().format('YYYY-MM-DD') })
    .pipe gulp.dest('lib')
    .pipe gulp.dest('site/assets/scripts')

gulp.task 'coffee:site', ->
  gulp.src 'site/assets/_coffee/*.coffee'
    .pipe cache('coffee:site')
    .pipe coffee().on('error', gutil.log)
    .pipe gulp.dest('site/assets/scripts')

gulp.task 'copy:vendor', ->
  gulp.src([
    'vendor/bower/jquery/dist/jquery.min.js'
    'vendor/bower/simple-module/lib/module.js'
    'vendor/bower/simple-uploader/lib/uploader.js'
    'vendor/bower/simple-hotkeys/lib/hotkeys.js'
  ])
  .pipe gulp.dest('site/assets/scripts')

gulp.task 'coffee:spec', ->
  gulp.src 'spec/src/**/*.coffee'
    .pipe cache('coffee:spec')
    .pipe coffee().on('error', gutil.log)
    .pipe gulp.dest('spec')

gulp.task 'site', ['sass:simditor', 'sass:site', 'coffee:simditor', 'coffee:site', 'copy:vendor'], ->
  gulp.start 'jekyll'

gulp.task 'jekyll', (cb) ->
  child.exec 'jekyll build --source ./site --destination ./_site', (err) ->
    return cb(err) if err
    cb()
