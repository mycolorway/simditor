class AlignleftButton extends Button

  name: 'alignleft'

  icon: 'align-left'

  htmlTag: 'p, h1, h2, h3, h4'

  shortcut: 'Cmd + Shift + L'

  status: ($node) ->
    return true unless $node?
    return unless @editor.util.isBlockNode $node

    @setDisabled !$node.is(@htmlTag)
    @setActive !@disabled
    return true if @disabled

    aligment = $node.data("align")
    @setActive aligment == undefined or aligment == "left"
    @active

  command: (param) ->
    @editor.alignment.left @htmlTag

Simditor.Toolbar.addButton AlignleftButton
