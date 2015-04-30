class AligncenterButton extends AlignButton

  name: 'aligncenter'

  icon: 'align-center'

  shortcut: 'Cmd + Shift + E'

  _status: ($node) ->
    $node.data("align") == "center"

  command: (param) ->
    @editor.alignment.center @htmlTag

Simditor.Toolbar.addButton AligncenterButton
