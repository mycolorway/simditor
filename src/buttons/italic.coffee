
class ItalicButton extends Button

  name: 'italic'

  icon: 'italic'

  title: '斜体文字'

  htmlTag: 'i'

  command: ->
    document.execCommand 'italic'
    @active = !@active


Simditor.Toolbar.addButton(ItalicButton)

