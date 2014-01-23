
class BoldButton extends Button

  name: 'bold'

  icon: 'bold'

  title: '加粗文字'

  htmlTag: 'b, strong'

  shortcut: 66

  status: ->
    active = document.queryCommandState('bold') is true
    @setActive active
    active

  command: ->
    super()
    document.execCommand 'bold'
    @toolbar.editor.trigger 'valuechanged'
    @toolbar.editor.trigger 'selectionchanged'


Simditor.Toolbar.addButton(BoldButton)
