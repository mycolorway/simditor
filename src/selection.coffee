
Selection =

  _load: ->
    @sel = document.getSelection()

  _init: ->

  getRange: ->
    if !@focused or !@sel.rangeCount
      return null

    return @sel.getRangeAt 0

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
    @setRangeAfter node

  setRangeAfter: (node, range = @getRange()) ->
    return unless range?

    node = $(node)[0]
    range.setEndAfter node
    range.collapse()
    @sel.removeAllRanges()
    @sel.addRange range

  setRangeBefore: (node, range = @getRange()) ->
    return unless range?

    node = $(node)[0]
    range.setEndBefore node
    range.collapse()
    @sel.removeAllRanges()
    @sel.addRange range


