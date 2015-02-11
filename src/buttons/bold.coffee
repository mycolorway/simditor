
class BoldButton extends Button

  name: 'bold'

  icon: 'bold'

  htmlTag: 'b, strong'

  disableTag: 'pre'

  shortcut: 'cmd+b'

  _init: ->
    if @editor.util.os.mac
      @title = @title + ' ( Cmd + b )'
    else
      @title = @title + ' ( Ctrl + b )'
      @shortcut = 'ctrl+b'
    super()

  status: ($node) ->
    @setDisabled $node.is(@disableTag) if $node?
    return true if @disabled

    active = document.queryCommandState('bold') is true
    @setActive active
    active

  command: ->
    document.execCommand 'bold'
    unless @editor.util.support.oninput
      @editor.trigger 'valuechanged'

    # bold command won't trigger selectionchange event automatically
    $(document).trigger 'selectionchange'


Simditor.Toolbar.addButton BoldButton
