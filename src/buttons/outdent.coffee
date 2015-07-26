
class OutdentButton extends Button

  name: 'outdent'

  icon: 'outdent'

  _init: ->
    @title = @_t(@name) + ' (Shift + Tab)'
    super()

  _status: ->

  command: ->
    @editor.indentation.indent(true)


Simditor.Toolbar.addButton OutdentButton
