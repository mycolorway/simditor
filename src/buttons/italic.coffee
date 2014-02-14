
class ItalicButton extends Button

  name: 'italic'

  icon: 'italic'

  title: '斜体文字'

  htmlTag: 'i'

  disableTag: 'pre'

  shortcut: 'cmd+73'

  status: ($node) ->
    @setDisabled $node.is(@disableTag) if $node?
    return @disabled if @disabled

    active = document.queryCommandState('italic') is true
    @setActive active
    active

  command: ->
    document.execCommand 'italic'
    @editor.trigger 'valuechanged'
    @editor.trigger 'selectionchanged'


Simditor.Toolbar.addButton(ItalicButton)

