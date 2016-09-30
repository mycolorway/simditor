
class ItalicButton extends Button

  name: 'italic'

  icon: 'italic'

  htmlTag: 'i'

  disableTag: 'pre'

  shortcut: 'cmd+i'

  _init: ->
    if @editor.util.os.mac
      @title = "#{@title} ( Cmd + i )"
    else
      @title = "#{@title} ( Ctrl + i )"
      @shortcut = 'ctrl+i'

    super()

  _activeStatus: ->
    active = document.queryCommandState('italic') is true
    @setActive active
    @active

  command: ->
    # Use span[style] instead of <i>
    document.execCommand 'styleWithCSS', false, true
    document.execCommand 'italic'
    document.execCommand 'styleWithCSS', false, false
    unless @editor.util.support.oninput
      @editor.trigger 'valuechanged'

    # italic command won't trigger selectionchange event automatically
    $(document).trigger 'selectionchange'


Simditor.Toolbar.addButton ItalicButton
