
class IndentButton extends Button

  name: 'indent'

  icon: 'indent'

  title: '向右缩进'

  status: ($node) ->
    true

  command: ->
    @editor.inputManager.indent()


Simditor.Toolbar.addButton(IndentButton)

