class AlignrightButton extends Button

  name: 'alignright'

  icon: 'align-right'

  htmlTag: 'p, h1, h2, h3, h4'

  shortcut: 'Cmd + Shift + R'

  status: ($node) ->
    return true unless $node?
    return unless @editor.util.isBlockNode $node

    @setDisabled !$node.is(@htmlTag)
    @setActive !@disabled
    return true if @disabled

    @setActive $node.data("align") == "right"
    @active

  command: (param) ->
    @editor.alignment.right @htmlTag

Simditor.Toolbar.addButton AlignrightButton
