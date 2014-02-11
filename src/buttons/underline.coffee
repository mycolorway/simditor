
class UnderlineButton extends Button

  name: 'underline'

  icon: 'underline'

  title: '下划线文字'

  htmlTag: 'u'

  disableTag: 'pre'

  shortcut: 'cmd+85'

  status: ($node) ->
    @setDisabled $node.is(@disableTag) if $node?
    return @disabled if @disabled

    active = document.queryCommandState('underline') is true
    @setActive active
    active

  command: ->
    document.execCommand 'underline'
    @toolbar.editor.trigger 'valuechanged'
    @toolbar.editor.trigger 'selectionchanged'


Simditor.Toolbar.addButton(UnderlineButton)


