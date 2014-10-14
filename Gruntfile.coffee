module.exports = (grunt) ->

  grunt.initConfig

    pkg: grunt.file.readJSON 'package.json'

    coffee:
      simditor:
        options:
          bare: true
        files:
          'lib/simditor.js': [
            'src/selection.coffee',
            'src/formatter.coffee',
            'src/inputManager.coffee',
            'src/keystroke.coffee',
            'src/undoManager.coffee',
            'src/util.coffee',
            'src/toolbar.coffee',
            'src/core.coffee',
            'src/i18n.coffee',
            'src/buttons/button.coffee',
            'src/buttons/popover.coffee',
            'src/buttons/title.coffee',
            'src/buttons/bold.coffee',
            'src/buttons/italic.coffee',
            'src/buttons/underline.coffee',
            'src/buttons/color.coffee',
            'src/buttons/list.coffee',
            'src/buttons/blockquote.coffee',
            'src/buttons/code.coffee',
            'src/buttons/link.coffee',
            'src/buttons/image.coffee',
            'src/buttons/indent.coffee',
            'src/buttons/outdent.coffee',
            'src/buttons/hr.coffee',
            'src/buttons/table.coffee',
            'src/buttons/strikethrough.coffee'
          ]
      site:
        expand: true
        flatten: true
        src: 'site/assets/_coffee/*.coffee'
        dest: 'site/assets/scripts/'
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
        template: 'umd'
        amdModuleId: 'simditor'
        objectToExport: 'Simditor'
        globalAlias: 'Simditor'
        deps:
          'default': ['$', 'SimpleModule']
          amd: ['jquery', 'simple-module']
          cjs: ['jquery', 'simple-module']
          global:
            items: ['jQuery', 'SimpleModule']
            prefix: ''

    copy:
      vendor:
        files: [{
          src: 'vendor/bower/jquery/dist/jquery.min.js',
          dest: 'site/assets/scripts/jquery.min.js'
        }, {
          src: 'vendor/bower/fontawesome/css/font-awesome.css',
          dest: 'site/assets/styles/font-awesome.css'
        },{
          expand: true,
          flatten: true,
          src: 'vendor/bower/fontawesome/fonts/*',
          dest: 'site/assets/fonts/'
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
          expand: true,
          flatten: true
          src: 'styles/*',
          dest: 'package/styles/'
        }, {
          src: 'vendor/bower/fontawesome/css/font-awesome.css',
          dest: 'package/styles/font-awesome.css'
        }, {
          expand: true,
          flatten: true
          src: 'vendor/bower/fontawesome/fonts/*',
          dest: 'package/fonts/'
        }, {
          src: 'site/assets/images/image.png',
          dest: 'package/images/image.png'
        }, {
          src: 'site/assets/images/loading-upload.gif',
          dest: 'package/images/loading-upload.gif'
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
        tasks: ['sass:site', 'shell']
      siteScripts:
        files: ['site/assets/_coffee/*.coffee']
        tasks: ['coffee:site', 'jekyll']
      jekyll:
        files: ['site/**/*.html', 'site/**/*.md', 'site/**/*.yml']
        tasks: ['jekyll']

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
        files:
          'package/scripts/module.min.js': 'package/scripts/module.js'
          'package/scripts/uploader.min.js': 'package/scripts/uploader.js'
          'package/scripts/simditor.min.js': 'package/scripts/simditor.js'

    compress:
      package:
        options:
          archive: 'package/simditor-<%= pkg.version %>.zip'
        files: [{
          expand: true,
          cwd: 'package/'
          src: '**',
          dest: './'
        }]

    clean:
      package:
        src: ['package/']


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

  grunt.registerTask 'default', ['site', 'express', 'watch']
  grunt.registerTask 'site', ['sass', 'coffee', 'umd', 'copy:vendor', 'copy:scripts', 'copy:styles', 'jekyll']
  grunt.registerTask 'package', ['clean:package', 'copy:package', 'uglify:simditor', 'compress']

