
class IndentButton extends Button

  name: 'indent'

  icon: 'indent'

  title: Simditor._t('indent') + ' (Tab)'

  status: ($node) ->
    true

  command: ->
    @editor.util.indent()


Simditor.Toolbar.addButton IndentButton

