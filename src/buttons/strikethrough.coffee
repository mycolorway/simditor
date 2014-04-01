
class StrikethroughButton extends Button

  name: 'strikethrough'

  icon: 'strikethrough'

  title: '删除线文字'

  htmlTag: 'strike'

  disableTag: 'pre'

  status: ($node) ->
    @setDisabled $node.is(@disableTag) if $node?
    return true if @disabled

    active = document.queryCommandState('strikethrough') is true
    @setActive active
    active

  command: ->
    document.execCommand 'strikethrough'
    @editor.trigger 'valuechanged'
    @editor.trigger 'selectionchanged'


Simditor.Toolbar.addButton(StrikethroughButton)
