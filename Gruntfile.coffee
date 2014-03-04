module.exports = (grunt) ->

  grunt.initConfig

    pkg: grunt.file.readJSON 'package.json'

    concat:
      simditor:
        src: [
          'src/selection.coffee',
          'src/formatter.coffee',
          'src/inputManager.coffee',
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
          'src/buttons/outdent.coffee'
        ]
        dest: 'src/simditor.coffee'

    sass: 
      styles:
        options:
          style: 'expanded'
        files:
          'styles/simditor.css': 'styles/simditor.scss'
    coffee:
      module:
        files: 'lib/module.js': 'externals/simple-module/src/module.coffee'
      uploader:
        files: 'lib/uploader.js': 'externals/simple-uploader/src/uploader.coffee'
      simditor:
        files: 'lib/simditor.js': 'src/simditor.coffee'
    watch:
      styles:
        files: ['styles/*.scss']
        tasks: ['sass']
      scripts:
        files: ['src/*.coffee', 'src/buttons/*.coffee']
        tasks: ['concat', 'coffee']

  grunt.loadNpmTasks 'grunt-contrib-sass'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-concat'
  grunt.loadNpmTasks 'grunt-contrib-watch'

  grunt.registerTask 'default', ['watch']


