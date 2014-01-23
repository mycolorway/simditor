
class CodeButton extends Button

  name: 'code'

  icon: 'code'

  title: '插入代码'

  htmlTag: 'pre'

  command: ->
    super()
    editor =  @toolbar.editor
    range = editor.selection.getRange()
    startNode = range.startContainer
    endNode = range.endContainer
    $startBlock = editor.util.closestBlockEl(startNode)
    $endBlock = editor.util.closestBlockEl(endNode)

    range.setStartBefore $startBlock[0]
    range.setEndAfter $endBlock[0]

    $contents = $(range.extractContents())

    results = []
    $contents.children().each (i, el) =>
      converted = @_convertEl el
      for c in converted
        if results.length and results[results.length - 1].is(@htmlTag) and c.is(@htmlTag)
          results[results.length - 1].append(c.contents())
        else
          results.push(c)
    
    range.insertNode node[0] for node in results.reverse()
    editor.selection.selectRange(range)

    @toolbar.editor.trigger 'valuechanged'
    @toolbar.editor.trigger 'selectionchanged'

  _convertEl: (el) ->
    editor = @toolbar.editor
    $el = $(el)
    results = []

    if $el.is @htmlTag
      block = $('<p/>').append($el.html().replace('\n', '<br/>'))
      results.push block
    else
      codeStr = editor.formatter.clearHtml($el)
      block = $('<' + @htmlTag + '/>').append(codeStr)
      results.push(block)

    results


Simditor.Toolbar.addButton(CodeButton)


