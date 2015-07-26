
class IndentButton extends Button

  name: 'indent'

  icon: 'indent'

  _init: ->
    @title = @_t(@name) + ' (Tab)'
    super()

  _status: ->

  command: ->
    @editor.indentation.indent()


Simditor.Toolbar.addButton IndentButton
