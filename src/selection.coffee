
Selection =

  _load: ->
    @sel = document.getSelection()

  _init: ->

  getRange: ->
    if !@focused or !@sel.rangeCount
      return null

    return @sel.getRangeAt 0

  selectRange: (range) ->
    @sel.removeAllRanges()
    @sel.addRange(range)

  rangeAtEndOf: (node, range = @getRange()) ->
    return unless range?

    node = $(node)[0]
    endNode = range.endContainer
    #node.normalize()

    if range.endOffset != @getNodeLength endNode
      return false

    if node == endNode
      return true
    else if !$.contains(node, endNode)
      return false

    result = true
    $(endNode).parentsUntil(node).addBack().each (i, n) =>
      nodes = $(n).parent().contents().filter ->
        !(this.nodeType == 3 && !this.nodeValue)
      result = false unless nodes.last().get(0) == n

    result

  rangeAtStartOf: (node, range = @getRange()) ->
    return unless range?

    node = $(node)[0]
    startNode = range.startContainer

    if range.startOffset != 0
      return false

    if node == startNode
      return true
    else if !$.contains(node, startNode)
      return false

    result = true
    $(startNode).parentsUntil(node).addBack().each (i, n) =>
      nodes = $(n).parent().contents().filter ->
        !(this.nodeType == 3 && !this.nodeValue)
      result = false unless nodes.first().get(0) == n

    result

  insertNode: (node, range = @getRange()) ->
    return unless range?

    node = $(node)[0]
    range.insertNode node
    @setCaretAfter node

  setCaretAfter: (node, range = @getRange()) ->
    return unless range?

    node = $(node)[0]
    range.setEndAfter node
    range.collapse()
    @selectRange range

  setCaretBefore: (node, range = @getRange()) ->
    return unless range?

    node = $(node)[0]
    range.setEndBefore node
    range.collapse()
    @selectRange range

  setCaretAtStartOf: (node, range = @getRange()) ->
    node = $(node).get(0)
    range.setEnd(node, 0)
    range.collapse()
    @selectRange range

  setCaretAtEndOf: (node, range = @getRange()) ->
    node = $(node).get(0)
    nodeLength = @getNodeLength node
    nodeLength -= 1 if node.nodeType != 3 and nodeLength > 0 and $(node).contents().last().is('br')
    range.setEnd(node, nodeLength)
    range.collapse()
    @selectRange range

  deleteRangeContents: (range = @getRange()) ->
    range.deleteContents()

  breakBlockEl: (el, range = @getRange()) ->
    $el = $(el)
    return $el unless range.collapsed
    range.setStartBefore $el.get(0)
    return $el if range.collapsed
    $el.before range.extractContents()

  saveSelection: () ->
    return if @_selectionSaved

    range = @getRange()
    startCaret = $('<span/>').addClass('simditor-caret-start')
    endCaret = $('<span/>').addClass('simditor-caret-end')

    range.insertNode(startCaret[0])
    range.collapse()
    range.insertNode(endCaret[0])

    @sel.removeAllRanges()
    @_selectionSaved = true

  restoreSelection: () ->
    return false unless @_selectionSaved

    startCaret = @body.find('.simditor-caret-start')
    endCaret = @body.find('.simditor-caret-end')

    if startCaret.length and endCaret.length
      startContainer = startCaret.parent()
      startOffset = startContainer.contents().index(startCaret)
      endContainer = endCaret.parent()
      endOffset = endContainer.contents().index(endCaret)

      if startContainer[0] == endContainer[0]
        endOffset -= 1;

      range = document.createRange()
      range.setStart(startContainer.get(0), startOffset)
      range.setEnd(endContainer.get(0), endOffset)

      startCaret.remove()
      endCaret.remove()
      @selectRange range
    else
      startCaret.remove()
      endCaret.remove()

    @_selectionSaved = false
    range

