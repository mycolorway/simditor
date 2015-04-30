class AligncenterButton extends Button

  name: 'aligncenter'

  icon: 'align-center'

  htmlTag: 'p, h1, h2, h3, h4'

  shortcut: 'Cmd + Shift + E'

  status: ($node) ->
    return true unless $node?
    return unless @editor.util.isBlockNode $node

    @setDisabled !$node.is(@htmlTag)
    @setActive !@disabled
    return true if @disabled

    @setActive $node.data("align") == "center"
    @active

  command: (param) ->
    @editor.alignment.center @htmlTag

Simditor.Toolbar.addButton AligncenterButton
