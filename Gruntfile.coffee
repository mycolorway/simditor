module.exports = (grunt) ->

  grunt.initConfig

    pkg: grunt.file.readJSON 'package.json'

    concat:
      simditor:
        src: [
          'src/selection.coffee',
          'src/formatter.coffee',
          'src/inputManager.coffee',
          'src/keystroke.coffee',
          'src/undoManager.coffee',
          'src/util.coffee',
          'src/toolbar.coffee',
          'src/core.coffee',
          'src/buttons/button.coffee',
          'src/buttons/popover.coffee',
          'src/buttons/title.coffee',
          'src/buttons/bold.coffee',
          'src/buttons/italic.coffee',
          'src/buttons/underline.coffee',
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
        dest: 'src/simditor.coffee'
      all:
        src: [
          'lib/module.js',
          'lib/uploader.js',
          'lib/simditor.js'
        ]
        dest: 'lib/simditor-all.js'

    sass:
      simditor:
        options:
          style: 'expanded'
          bundleExec: true
        files:
          'styles/simditor.css': 'styles/simditor.scss'
      site:
        options:
          style: 'expanded'
          bundleExec: true
        files:
          'site/assets/styles/app.css': 'site/assets/_sass/app.scss'

    coffee:
      simditor:
        files:
          'lib/module.js': 'externals/simple-module/src/module.coffee'
          'lib/uploader.js': 'externals/simple-uploader/src/uploader.coffee'
          'lib/simditor.js': 'src/simditor.coffee'
      site:
        expand: true
        flatten: true
        src: 'site/assets/_coffee/*.coffee'
        dest: 'site/assets/scripts/'
        ext: '.js'

    copy:
      vendor:
        files: [{
          src: 'externals/jquery-2.1.0.min.js',
          dest: 'site/assets/scripts/jquery-2.1.0.min.js'
        }, {
          src: 'externals/font-awesome/font-awesome.css',
          dest: 'site/assets/styles/font-awesome.css'
        }, {
          expand: true,
          flatten: true,
          src: 'externals/font-awesome/fonts/*',
          dest: 'site/assets/fonts/'
        }]
      styles:
        src: 'styles/simditor.css',
        dest: 'site/assets/styles/simditor.css'
      scripts: 
        src: 'lib/simditor-all.js',
        dest: 'site/assets/scripts/simditor-all.js'
      package:
        files: [{
          expand: true,
          flatten: true
          src: 'lib/*',
          dest: 'package/scripts/js/'
        }, {
          src: 'src/simditor.coffee',
          dest: 'package/scripts/coffee/simditor.coffee'
        }, {
          src: 'externals/simple-module/src/module.coffee',
          dest: 'package/scripts/coffee/module.coffee'
        }, {
          src: 'externals/simple-uploader/src/uploader.coffee',
          dest: 'package/scripts/coffee/uploader.coffee'
        }, {
          expand: true,
          flatten: true
          src: 'styles/*',
          dest: 'package/styles/'
        }, {
          src: 'externals/font-awesome/font-awesome.css',
          dest: 'package/styles/font-awesome.css'
        }, {
          expand: true,
          flatten: true
          src: 'externals/font-awesome/fonts/*',
          dest: 'package/fonts/'
        }, {
          expand: true,
          flatten: true
          src: 'site/assets/images/*',
          dest: 'package/images/'
        }]

    watch:
      styles:
        files: ['styles/*.scss']
        tasks: ['sass:simditor', 'copy:styles', 'shell']
      scripts:
        files: ['src/*.coffee', 'src/buttons/*.coffee']
        tasks: ['concat:simditor', 'coffee:simditor', 'concat:all', 'copy:scripts', 'shell']
      siteStyles:
        files: ['site/assets/_sass/*.scss']
        tasks: ['sass:site', 'shell']
      siteScripts:
        files: ['site/assets/_coffee/*.coffee']
        tasks: ['coffee:site', 'shell']
      jekyll:
        files: ['site/**/*.html', 'site/**/*.md']
        tasks: ['shell']

    shell:
      jekyll:
        command: 'bundle exec jekyll build'

    express:
      server:
        options:
          server: 'externals/express.js'
          bases: '_site'

    uglify:
      package:
        files:
          'package/scripts/js/simditor-all.min.js': 'package/scripts/js/simditor-all.js'
          'package/scripts/js/simditor.min.js': 'package/scripts/js/simditor.js'

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


  grunt.loadNpmTasks 'grunt-contrib-sass'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-concat'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-compress'
  grunt.loadNpmTasks 'grunt-express'
  grunt.loadNpmTasks 'grunt-shell'

  grunt.registerTask 'default', ['site', 'express', 'watch']
  grunt.registerTask 'site', ['sass', 'concat:simditor', 'coffee', 'concat:all', 'copy:vendor', 'copy:styles', 'copy:scripts', 'shell']
  grunt.registerTask 'package', ['copy:package', 'uglify', 'compress']

