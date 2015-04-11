
class OutdentButton extends Button

  name: 'outdent'

  icon: 'outdent'

  _init: ->
    @title = @_t(@name) + ' (Shift + Tab)'
    super()

  status: ($node) ->
    true

  command: ->
    @editor.indentation.indent(true)


Simditor.Toolbar.addButton OutdentButton
