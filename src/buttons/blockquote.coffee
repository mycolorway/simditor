
class BlockquoteButton extends Button

  name: 'blockquote'

  icon: 'quote-left'

  htmlTag: 'blockquote'

  disableTag: 'pre, table'

  command: ->
    range = @editor.selection.getRange()
    startNode = range.startContainer
    endNode = range.endContainer
    $startBlock = @editor.util.furthestBlockEl(startNode)
    $endBlock = @editor.util.furthestBlockEl(endNode)

    @editor.selection.save()

    range.setStartBefore $startBlock[0]
    range.setEndAfter $endBlock[0]

    $contents = $(range.extractContents())

    results = []
    $contents.children().each (i, el) =>
      converted = @_convertEl el
      for c in converted
        if results.length and results[results.length - 1].is(@htmlTag) and c.is(@htmlTag)
          results[results.length - 1].append(c.children())
        else
          results.push(c)

    range.insertNode node[0] for node in results.reverse()
    @editor.selection.restore()

    @editor.trigger 'valuechanged'

  _convertEl: (el) ->
    $el = $(el)
    results = []

    if $el.is @htmlTag
      $el.children().each (i, node) =>
        results.push $(node)
    else
      block = $('<' + @htmlTag + '/>').append($el)
      results.push(block)

    results



Simditor.Toolbar.addButton BlockquoteButton

