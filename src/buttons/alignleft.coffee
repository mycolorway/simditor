class AlignleftButton extends AlignButton

  name: 'alignleft'

  icon: 'align-left'

  shortcut: 'Cmd + Shift + L'

  _status: ($node) ->
    aligment = $node.data("align")
    aligment == undefined or aligment == "left"

  command: (param) ->
    @editor.alignment.left @htmlTag

Simditor.Toolbar.addButton AlignleftButton
