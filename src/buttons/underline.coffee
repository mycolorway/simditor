
class UnderlineButton extends Button

  name: 'underline'

  icon: 'underline'

  title: '下划线文字'

  htmlTag: 'u'

  shortcut: 85

  command: ->
    document.execCommand 'underline'
    @active = !@active


Simditor.Toolbar.addButton(UnderlineButton)


