
class BoldButton extends Button

  name: 'bold'

  icon: 'bold'

  title: '加粗文字'

  htmlTag: 'b, strong'

  disableTag: 'pre'

  shortcut: 'cmd+66'

  status: ($node) ->
    @setDisabled $node.is(@disableTag) if $node?
    return true if @disabled

    active = document.queryCommandState('bold') is true
    @setActive active
    active

  command: ->
    document.execCommand 'bold'
    @editor.trigger 'valuechanged'
    @editor.trigger 'selectionchanged'


Simditor.Toolbar.addButton(BoldButton)
