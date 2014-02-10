
class BoldButton extends Button

  name: 'bold'

  icon: 'bold'

  title: '加粗文字'

  htmlTag: 'b, strong'

  disableTag: 'pre'

  shortcut: 'cmd+66'

  status: ($node) ->
    @setDisabled $node.is(@disableTag) if $node?
    return @disabled if @disabled

    active = document.queryCommandState('bold') is true
    @setActive active
    active

  command: ->
    document.execCommand 'bold'
    @toolbar.editor.trigger 'valuechanged'
    @toolbar.editor.trigger 'selectionchanged'


Simditor.Toolbar.addButton(BoldButton)
