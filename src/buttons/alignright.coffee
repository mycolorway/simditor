class AlignrightButton extends AlignButton

  name: 'alignright'

  icon: 'align-right'

  shortcut: 'Cmd + Shift + R'

  _status: ($node) ->
    $node.data("align") == "right"

  command: (param) ->
    @editor.alignment.right @htmlTag

Simditor.Toolbar.addButton AlignrightButton
