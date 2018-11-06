
class IndentButton extends Button

  name: 'indent'

  icon: 'indent'

  _init: ->
    hotkey = if @editor.opts.tabIndent == false then '' else ' (Tab)'
    @title = @_t(@name) + hotkey
    super()

  _status: ->

  command: ->
    @editor.indentation.indent()


Simditor.Toolbar.addButton IndentButton
