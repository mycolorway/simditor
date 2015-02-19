
class SourceButton extends Button

  name: 'source'

  icon: 'source'

  _init: ->
    super()

  status: ($node) ->
    true

  command: ->
    @active = !@active
    @el.toggleClass 'active', @active
    @editor.el.toggleClass 'simditor-source-code' ,@active

Simditor.Toolbar.addButton SourceButton

