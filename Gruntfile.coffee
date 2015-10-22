module.exports = (grunt) ->

  grunt.initConfig

    pkg: grunt.file.readJSON 'package.json'

    coffee:
      simditor:
        options:
          join: true
          bare: true
        files:
          'lib/simditor.js': [
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
      site:
        expand: true
        flatten: true
        src: 'site/assets/_coffee/*.coffee'
        dest: 'site/assets/scripts/'
        ext: '.js'

      moduleSpec:
        expand: true
        flatten: true
        src: 'spec/src/*.coffee'
        dest: 'spec/'
        ext: '.js'

      buttonSpec:
        expand: true
        flatten: true
        src: 'spec/src/buttons/*.coffee'
        dest: 'spec/buttons/'
        ext: '.js'

    sass:
      simditor:
        options:
          style: 'expanded'
          bundleExec: true
          sourcemap: 'none'
        files:
          'styles/simditor.css': 'styles/simditor.scss'
      site:
        options:
          style: 'expanded'
          bundleExec: true
          sourcemap: 'none'
        files:
          'site/assets/styles/app.css': 'site/assets/_sass/app.scss'
          'site/assets/styles/mobile.css': 'site/assets/_sass/mobile.scss'

    umd:
      all:
        src: 'lib/simditor.js'
        template: 'umd.hbs'
        amdModuleId: 'simditor'
        objectToExport: 'Simditor'
        globalAlias: 'Simditor'
        deps:
          'default': ['$', 'SimpleModule', 'simpleHotkeys', 'simpleUploader']
          amd: ['jquery', 'simple-module', 'simple-hotkeys', 'simple-uploader']
          cjs: ['jquery', 'simple-module', 'simple-hotkeys', 'simple-uploader']
          global:
            items: ['jQuery', 'SimpleModule', 'simple.hotkeys', 'simple.uploader']
            prefix: ''

    copy:
      vendor:
        files: [{
          src: 'vendor/bower/jquery/dist/jquery.min.js',
          dest: 'site/assets/scripts/jquery.min.js'
        }]
      styles:
        files: [{
          src: 'styles/simditor.css',
          dest: 'site/assets/styles/simditor.css'
        }]
      scripts:
        files: [{
          src: 'vendor/bower/simple-module/lib/module.js',
          dest: 'site/assets/scripts/module.js'
        }, {
          src: 'vendor/bower/simple-uploader/lib/uploader.js',
          dest: 'site/assets/scripts/uploader.js'
        }, {
          src: 'vendor/bower/simple-hotkeys/lib/hotkeys.js',
          dest: 'site/assets/scripts/hotkeys.js'
        }, {
          src: 'lib/simditor.js',
          dest: 'site/assets/scripts/simditor.js'
        }]

      package:
        files: [{
          expand: true,
          flatten: true
          src: 'lib/*',
          dest: 'package/scripts/'
        }, {
          src: 'vendor/bower/jquery/dist/jquery.min.js',
          dest: 'package/scripts/jquery.min.js'
        }, {
          src: 'vendor/bower/simple-module/lib/module.js',
          dest: 'package/scripts/module.js'
        }, {
          src: 'vendor/bower/simple-uploader/lib/uploader.js',
          dest: 'package/scripts/uploader.js'
        }, {
          src: 'vendor/bower/simple-hotkeys/lib/hotkeys.js',
          dest: 'package/scripts/hotkeys.js'
        }, {
          expand: true,
          flatten: true
          src: 'styles/*',
          dest: 'package/styles/'
        }, {
          src: 'site/assets/images/image.png',
          dest: 'package/images/image.png'
        }]

    watch:
      styles:
        files: ['styles/*.scss']
        tasks: ['sass:simditor', 'copy:styles', 'jekyll']
      scripts:
        files: ['src/*.coffee', 'src/buttons/*.coffee']
        tasks: ['coffee:simditor', 'umd', 'copy:scripts', 'jekyll']
      siteStyles:
        files: ['site/assets/_sass/*.scss']
        tasks: ['sass:site', 'jekyll']
      siteScripts:
        files: ['site/assets/_coffee/*.coffee']
        tasks: ['coffee:site', 'jekyll']
      jekyll:
        files: ['site/**/*.html', 'site/**/*.md', 'site/**/*.yml']
        tasks: ['jekyll']
      moduleSpec:
        files: ['spec/src/*.coffee']
        tasks: ['coffee:moduleSpec']
      buttonSpec:
        files: ['spec/src/buttons/*.coffee']
        tasks: ['coffee:buttonSpec']

    jekyll:
      site:
        options:
          bundleExec: true
          config: 'jekyll.yml'

    express:
      server:
        options:
          server: 'server.js'
          bases: '_site'

    uglify:
      simditor:
        options:
          preserveComments: 'some'
        files:
          'package/scripts/module.min.js': 'package/scripts/module.js'
          'package/scripts/uploader.min.js': 'package/scripts/uploader.js'
          'package/scripts/hotkeys.min.js': 'package/scripts/hotkeys.js'
          'package/scripts/simditor.min.js': 'package/scripts/simditor.js'

    usebanner:
      simditor:
        options:
          banner: '''/*!
 * Simditor v<%= pkg.version %>
 * http://simditor.tower.im/
 * <%= grunt.template.today("yyyy-mm-dd") %>
 */'''
        files:
          src: ['lib/simditor.js', 'styles/simditor.css']

    compress:
      package:
        options:
          archive: 'package/simditor-<%= pkg.version %>.zip'
        files: [{
          expand: true,
          cwd: 'package/'
          src: '**',
          dest: 'simditor-<%= pkg.version %>/'
        }]

    clean:
      package:
        src: ['package/']

    jasmine:
      test:
        src: ['lib/**/*.js']
        options:
          outfile: 'spec/index.html'
          styles: [
            'styles/simditor.css'
          ]
          specs: [
            'spec/*.js'
            'spec/buttons/*.js'
          ]
          vendor: [
            'vendor/bower/jquery/dist/jquery.min.js'
            'vendor/bower/simple-module/lib/module.js'
            'vendor/bower/simple-uploader/lib/uploader.js'
            'vendor/bower/simple-hotkeys/lib/hotkeys.js'
          ]

    curl:
      fonticons:
        src: "http://use.fonticons.com/kits/d7611efe/d7611efe.css"
        dest: "styles/fonticon.scss"


  grunt.loadNpmTasks 'grunt-contrib-sass'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-compress'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-umd'
  grunt.loadNpmTasks 'grunt-express'
  grunt.loadNpmTasks 'grunt-jekyll'
  grunt.loadNpmTasks 'grunt-contrib-jasmine'
  grunt.loadNpmTasks 'grunt-banner'
  grunt.loadNpmTasks 'grunt-curl'

  grunt.registerTask 'default', ['site', 'express', 'watch']
  grunt.registerTask 'site', ['sass', 'coffee', 'umd', 'copy:vendor', 'copy:scripts', 'copy:styles', 'usebanner', 'jekyll']
  grunt.registerTask 'test', ['coffee:moduleSpec', 'coffee:buttonSpec', 'jasmine']
  grunt.registerTask 'package', ['clean:package', 'copy:package', 'uglify:simditor', 'compress']

  grunt.registerTask 'fonticons', ['curl']
