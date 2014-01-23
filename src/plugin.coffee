
class Plugin

  opts: {}

  constructor: (@editor) ->
    $.extend(@opts, @editor.opts)

  _init: ->
