
class OutdentButton extends Button

  name: 'outdent'

  icon: 'outdent'

  title: Simditor._t('outdent') + ' (Shift + Tab)'

  status: ($node) ->
    true

  command: ->
    @editor.util.outdent()


Simditor.Toolbar.addButton OutdentButton


