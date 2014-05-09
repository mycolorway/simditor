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
          'vendor/bower/simple-module/lib/module.js',
          'vendor/bower/simple-uploader/lib/uploader.js',
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
          'lib/simditor.js': 'src/simditor.coffee'
      site:
        expand: true
        flatten: true
        src: 'site/assets/_coffee/*.coffee'
        dest: 'site/assets/scripts/'
        ext: '.js'

    copy:
      site:
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
        }, {
          src: 'styles/simditor.css',
          dest: 'site/assets/styles/simditor.css'
        }, {
          src: 'lib/simditor-all.js',
          dest: 'site/assets/scripts/simditor-all.js'
        }, {
          src: 'lib/simditor-all.min.js',
          dest: 'site/assets/scripts/simditor-all.min.js'
        }]

      styles:
        files: [{
          src: 'styles/simditor.css',
          dest: 'site/assets/styles/simditor.css'
        }]
      scripts:
        files: [{
          src: 'lib/simditor-all.js',
          dest: 'site/assets/scripts/simditor-all.js'
        }, {
          src: 'lib/simditor-all.min.js',
          dest: 'site/assets/scripts/simditor-all.min.js'
        }]

      package:
        files: [{
          expand: true,
          flatten: true
          src: 'lib/*',
          dest: 'package/scripts/js/'
        }, {
          src: 'vendor/bower/jquery/dist/jquery.min.js',
          dest: 'package/scripts/js/jquery.min.js'
        }, {
          src: 'vendor/bower/simple-module/lib/module.js',
          dest: 'package/scripts/js/module.js'
        }, {
          src: 'vendor/bower/simple-uploader/lib/uploader.js',
          dest: 'package/scripts/js/uploader.js'
        }, {
          src: 'src/simditor.coffee',
          dest: 'package/scripts/coffee/simditor.coffee'
        }, {
          src: 'vendor/bower/simple-module/src/module.coffee',
          dest: 'package/scripts/coffee/module.coffee'
        }, {
          src: 'vendor/bower/simple-uploader/src/uploader.coffee',
          dest: 'package/scripts/coffee/uploader.coffee'
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
        tasks: ['sass:simditor', 'copy:styles', 'shell']
      scripts:
        files: ['src/*.coffee', 'src/buttons/*.coffee']
        tasks: ['concat:simditor', 'coffee:simditor', 'concat:all', 'copy:site', 'shell']
      siteStyles:
        files: ['site/assets/_sass/*.scss']
        tasks: ['sass:site', 'shell']
      siteScripts:
        files: ['site/assets/_coffee/*.coffee']
        tasks: ['coffee:site', 'shell']
      jekyll:
        files: ['site/**/*.html', 'site/**/*.md', 'site/**/*.yml']
        tasks: ['shell']

    shell:
      jekyll:
        command: 'bundle exec jekyll build'

    express:
      server:
        options:
          server: 'server.js'
          bases: '_site'

    uglify:
      simditor:
        files:
          'lib/simditor-all.min.js': 'lib/simditor-all.js'
          'lib/simditor.min.js': 'lib/simditor.js'

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
  grunt.loadNpmTasks 'grunt-contrib-concat'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-compress'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-express'
  grunt.loadNpmTasks 'grunt-shell'

  grunt.registerTask 'default', ['site', 'express', 'watch']
  grunt.registerTask 'site', ['sass', 'concat:simditor', 'coffee', 'concat:all', 'copy:site', 'shell']
  grunt.registerTask 'package', ['uglify:simditor', 'clean:package', 'copy:package', 'compress']

