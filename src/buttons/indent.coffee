
class IndentButton extends Button

  name: 'indent'

  icon: 'indent'

  title: '向右缩进（Tab）'

  status: ($node) ->
    true

  command: ->
    @editor.util.indent()


Simditor.Toolbar.addButton(IndentButton)

