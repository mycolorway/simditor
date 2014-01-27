
class LinkButton extends Button

  name: 'link'

  icon: 'link'

  title: '插入链接'

  htmlTag: 'a'

  command: ->
    super()
    editor =  @toolbar.editor
    range = editor.selection.getRange()
    startNode = range.startContainer
    endNode = range.endContainer
    $startBlock = editor.util.closestBlockEl(startNode)
    $endBlock = editor.util.closestBlockEl(endNode)

    $contents = $(range.extractContents())
    $link = $('<a/>', {
      href: 'http://www.example.com',
      target: '_blank',
      text: editor.formatter.clearHtml($contents.contents(), false) || '链接文字'
    })

    if $startBlock[0] == $endBlock[0]
      range.insertNode $link[0]
    else
      $newBlock = $('<p/>').append($link)
      range.insertNode $newBlock[0]

    range.selectNodeContents $link[0]
    editor.selection.selectRange range

    @toolbar.editor.trigger 'valuechanged'
    @toolbar.editor.trigger 'selectionchanged'


Simditor.Toolbar.addButton(LinkButton)

