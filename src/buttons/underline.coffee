
class UnderlineButton extends Button

  name: 'underline'

  icon: 'underline'

  htmlTag: 'u'

  disableTag: 'pre'

  shortcut: 'cmd+u'

  render: ->
    if @editor.util.os.mac
      @title = @title + ' ( Cmd + u )'
    else
      @title = @title + ' ( Ctrl + u )'
      @shortcut = 'ctrl+u'
    super()

  _activeStatus: ->
    active = document.queryCommandState('underline') is true
    @setActive active
    @active

  command: ->
    document.execCommand 'underline'
    unless @editor.util.support.oninput
      @editor.trigger 'valuechanged'

    # underline command won't trigger selectionchange event automatically
    $(document).trigger 'selectionchange'


Simditor.Toolbar.addButton UnderlineButton
