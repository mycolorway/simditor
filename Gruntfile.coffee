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
        ]
        dest: 'src/simditor.coffee'

    sass:
      simditor:
        options:
          style: 'expanded'
          bundleExec: true
        files:
          'styles/simditor.css': 'styles/simditor.scss'
    coffee:
      simditor:
        files:
          'lib/module.js': 'externals/simple-module/src/module.coffee'
          'lib/uploader.js': 'externals/simple-uploader/src/uploader.coffee'
          'lib/simditor.js': 'src/simditor.coffee'
      demo:
        files:
          'lib/simditor-all.js': [
            'externals/simple-module/src/module.coffee',
            'externals/simple-uploader/src/uploader.coffee',
            'src/simditor.coffee'
          ]
    watch:
      styles:
        files: ['styles/*.scss']
        tasks: ['sass:simditor']
      scripts:
        files: ['src/*.coffee', 'src/buttons/*.coffee']
        tasks: ['concat', 'coffee:simditor']
    express:
      server:
        options:
          port: 3000
          server: 'externals/express.js'
          bases: '../simditor'



  grunt.loadNpmTasks 'grunt-contrib-sass'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-concat'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-express'

  grunt.registerTask 'default', ['sass', 'coffee', 'watch']
  grunt.registerTask 'server', ['express', 'express-keepalive']

