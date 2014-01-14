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
            'src/format.coffee',
            'src/input.coffee',
            'src/selection.coffee',
            'src/util.coffee',
            'src/simditor.coffee'
          ]
    watch:
      styles:
        files: ['styles/*.scss']
        tasks: ['sass']
      scripts:
        files: ['src/*.coffee']
        tasks: ['coffee']

  grunt.loadNpmTasks 'grunt-contrib-sass'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-watch'

  grunt.registerTask 'default', ['watch']


