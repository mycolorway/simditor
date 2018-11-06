
class OutdentButton extends Button

  name: 'outdent'

  icon: 'outdent'

  _init: ->
    hotkey = if @editor.opts.tabIndent == false then '' else ' (Shift + Tab)'
    @title = @_t(@name) + hotkey
    super()

  _status: ->

  command: ->
    @editor.indentation.indent(true)


Simditor.Toolbar.addButton OutdentButton
