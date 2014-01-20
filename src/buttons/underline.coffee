
class UnderlineButton extends Button

  name: 'underline'

  icon: 'underline'

  title: '下划线文字'

  htmlTag: 'u'

  command: ->
    document.execCommand 'underline'
    @active = !@active


Simditor.Toolbar.addButton(UnderlineButton)


