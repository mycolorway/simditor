module.exports = (grunt) ->

  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'
    sass: 
      styles:
        options:
          style: 'expanded'
        files:
          'styles/simditor.css': 'styles/simditor.scss'
    coffee:
      scripts:
        options:
          join: true
        files:
          'scripts/simditor.js': [
            'src/widget.coffee',
            'src/plugin.coffee',
            'src/selection.coffee',
            'src/formatter.coffee',
            'src/inputManager.coffee',
            'src/undoManager.coffee',
            'src/util.coffee',
            'src/toolbar.coffee',
            'src/simditor.coffee',
            'src/buttons/button.coffee',
            'src/buttons/bold.coffee',
            'src/buttons/italic.coffee',
            'src/buttons/underline.coffee',
            'src/buttons/list.coffee',
            'src/buttons/blockquote.coffee',
            'src/buttons/code.coffee'
          ]
    watch:
      styles:
        files: ['styles/*.scss']
        tasks: ['sass']
      scripts:
        files: ['src/*.coffee', 'src/buttons/*.coffee']
        tasks: ['coffee']

  grunt.loadNpmTasks 'grunt-contrib-sass'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-watch'

  grunt.registerTask 'default', ['watch']


