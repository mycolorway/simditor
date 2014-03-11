
class OutdentButton extends Button

  name: 'outdent'

  icon: 'outdent'

  title: '向左缩进（Shift + Tab）'

  status: ($node) ->
    true

  command: ->
    @editor.util.outdent()


Simditor.Toolbar.addButton(OutdentButton)


