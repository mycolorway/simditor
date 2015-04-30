class AlignButton extends Button

  htmlTag: 'p, h1, h2, h3, h4'

  _init: ->
    unless @editor.util.os.mac
      @shortcut = @shortcut.replace "Cmd", "Ctrl"
    @title = @title + " ( #{@shortcut} )"
    super()

  status: ($node) ->
    return true unless $node?
    return unless @editor.util.isBlockNode $node

    @setDisabled !$node.is(@htmlTag)
    @setActive !@disabled
    return true if @disabled

    @setActive @_status($node)
    @active
