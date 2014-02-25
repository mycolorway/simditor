
class OutdentButton extends Button

  name: 'outdent'

  icon: 'outdent'

  title: '向左缩进'

  status: ($node) ->
    true

  command: ->
    @editor.inputManager.outdent()


Simditor.Toolbar.addButton(OutdentButton)


