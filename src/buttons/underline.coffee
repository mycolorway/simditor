
class UnderlineButton extends Button

  name: 'underline'

  icon: 'underline'

  title: '下划线文字'

  htmlTag: 'u'

  shortcut: 85

  status: ->
    active = document.queryCommandState('underline') is true
    @setActive active
    active

  command: ->
    document.execCommand 'underline'
    @status()


Simditor.Toolbar.addButton(UnderlineButton)


