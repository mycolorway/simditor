
class Selection extends SimpleModule

  @pluginName: 'Selection'

  _range: null

  _startNodes: null

  _endNodes: null

  _containerNode: null

  _nodes: null

  _blockNodes: null

  _rootNodes: null

  _init: ->
    @editor = @_module
    @_selection = document.getSelection()

    @editor.on 'selectionchanged', (e) =>
      @reset()
      @_range = @_selection.getRangeAt 0

    @editor.on 'blur', (e) =>
      @reset()

    @editor.on 'focus', (e) =>
      @reset()
      @_range = @_selection.getRangeAt 0

  reset: ->
    @_range = null
    @_startNodes = null
    @_endNodes = null
    @_containerNode = null
    @_nodes = null
    @_blockNodes = null
    @_rootNodes = null

  clear: ->
    try
      @_selection.removeAllRanges()
    catch e

    @reset()

  range: (range) ->
    if range
      @clear()
      @_selection.addRange range
      @_range = range

      # firefox won't auto focus while applying new range
      ffOrIE = @editor.util.browser.firefox or @editor.util.browser.msie
      @editor.body.focus() if !@editor.inputManager.focused and ffOrIE

    else if !@_range and @editor.inputManager.focused and @_selection.rangeCount
      @_range = @_selection.getRangeAt 0

    @_range

  startNodes: ->
    if @_range
      @_startNodes ||= do =>
        startNodes = $(@_range.startContainer).parentsUntil(@editor.body).get()
        startNodes.unshift @_range.startContainer
        $(startNodes)

    @_startNodes

  endNodes: ->
    if @_range
      @_endNodes ||= if @_range.collapsed
        @startNodes()
      else
        endNodes = $(@_range.endContainer).parentsUntil(@editor.body).get()
        endNodes.unshift @_range.endContainer
        $(endNodes)

    @_endNodes

  containerNode: ->
    if @_range
      @_containerNode ||= $(@_range.commonAncestorContainer)

    @_containerNode

  # all nodes in selection content
  nodes: ->
    if @_range
      @_nodes ||= do =>
        nodes = []

        if @startNodes().first().is(@endNodes().first())
          nodes = @startNodes().get()
        else
          @startNodes().each (i, node) =>
            $node = $ node
            if @endNodes().index($node) > -1
              nodes.push node
            else if $node.parent().is(@editor.body) or
                (sharedIndex = @endNodes().index($node.parent())) > -1
              if sharedIndex and sharedIndex > -1
                $endNode = @endNodes().eq(sharedIndex - 1)
              else
                $endNode = @endNodes().last()
              $nodes = $node.parent().contents()
              startIndex = $nodes.index($node)
              endIndex = $nodes.index($endNode)
              $.merge nodes, $nodes.slice(startIndex, endIndex).get()
            else
              $nodes = $node.parent().contents()
              index = $nodes.index($node)
              $.merge nodes, $nodes.slice(index).get()

          @endNodes().each (i, node) =>
            $node = $ node
            if $node.parent().is(@editor.body) or
                @startNodes().index($node.parent()) > -1
              nodes.push node
              return false
            else
              $nodes = $node.parent().contents()
              index = $nodes.index($node)
              $.merge nodes, $nodes.slice(0, index + 1)

        $($.unique(nodes))

    @_nodes

  # all block nodes in selection content
  blockNodes: ->
    return unless @_range

    @_blockNodes ||= do =>
      @nodes().filter (i, node) =>
        @editor.util.isBlockNode node

    @_blockNodes

  rootNodes: ->
    return unless @_range

    @_rootNodes ||= do =>
      @nodes().filter (i, node) =>
        $parent = $(node).parent()
        $parent.is(@editor.body) or $parent.is('blockquote')

    @_rootNodes

  rangeAtEndOf: (node, range = @range()) ->
    return unless range and range.collapsed

    node = $(node)[0]
    endNode = range.endContainer
    endNodeLength = @editor.util.getNodeLength endNode
    #node.normalize()

    beforeLastNode = range.endOffset == endNodeLength - 1
    lastNodeIsBr = $(endNode).contents().last().is('br')
    afterLastNode = range.endOffset == endNodeLength
    unless (beforeLastNode and lastNodeIsBr) or afterLastNode
      return false

    if node == endNode
      return true
    else if !$.contains(node, endNode)
      return false

    result = true
    $(endNode).parentsUntil(node).addBack().each (i, n) ->
      # remove empty text nodes
      nodes = $(n).parent().contents().filter ->
        !(this != n && this.nodeType == 3 && !this.nodeValue)
      $lastChild = nodes.last()
      isLastNode = $lastChild.get(0) == n
      beforeLastbr = $lastChild.is('br') and $lastChild.prev().get(0) == n
      unless isLastNode or beforeLastbr
        result = false
        return false

    result

  rangeAtStartOf: (node, range = @range()) ->
    return unless range and range.collapsed

    node = $(node)[0]
    startNode = range.startContainer

    if range.startOffset != 0
      return false

    if node == startNode
      return true
    else if !$.contains(node, startNode)
      return false

    result = true
    $(startNode).parentsUntil(node).addBack().each (i, n) ->
      # remove empty nodes
      nodes = $(n).parent().contents().filter ->
        !(this != n && this.nodeType == 3 && !this.nodeValue)
      result = false unless nodes.first().get(0) == n

    result

  insertNode: (node, range = @range()) ->
    return unless range

    node = $(node)[0]
    range.insertNode node
    @setRangeAfter node, range

  setRangeAfter: (node, range = @range()) ->
    return unless range?

    node = $(node)[0]
    range.setEndAfter node
    range.collapse(false)
    @range range

  setRangeBefore: (node, range = @range()) ->
    return unless range?

    node = $(node)[0]
    range.setEndBefore node
    range.collapse(false)
    @range range

  setRangeAtStartOf: (node, range = @range()) ->
    node = $(node).get(0)
    range.setEnd(node, 0)
    range.collapse(false)
    @range range

  setRangeAtEndOf: (node, range = @range()) ->
    # TODO: need refactor
    $node = $(node)
    node = $node[0]
    return unless node

    if $node.is('pre')
      contents = $node.contents()
      if contents.length > 0
        lastChild = contents.last()
        lastText = lastChild.text()
        lastChildLength = @editor.util.getNodeLength(lastChild[0])
        if lastText.charAt(lastText.length - 1) is '\n'
          range.setEnd(lastChild[0], lastChildLength - 1)
        else
          range.setEnd(lastChild[0], lastChildLength)
      else
        range.setEnd(node, 0)
    else
      nodeLength = @editor.util.getNodeLength node
      if node.nodeType != 3 and nodeLength > 0
        $lastNode = $(node).contents().last()
        if $lastNode.is('br')
          nodeLength -= 1
        else if $lastNode[0].nodeType != 3 and
            @editor.util.isEmptyNode($lastNode)
          $lastNode.append @editor.util.phBr
          node = $lastNode[0]
          nodeLength = 0

      range.setEnd(node, nodeLength)

    range.collapse(false)
    @range range

  deleteRangeContents: (range = @range()) ->
    startRange = range.cloneRange()
    endRange = range.cloneRange()
    startRange.collapse(true)
    endRange.collapse(false)

    # the default behavior of cmd+a is buggy
    atStartOfBody = @rangeAtStartOf(@editor.body, startRange)
    atEndOfBody = @rangeAtEndOf(@editor.body, endRange)
    if !range.collapsed and atStartOfBody and atEndOfBody
      @editor.body.empty()
      range.setStart @editor.body[0], 0
      range.collapse true
      @range range
    else
      range.deleteContents()

    range

  breakBlockEl: (el, range = @range()) ->
    $el = $(el)
    return $el unless range.collapsed
    range.setStartBefore $el.get(0)
    return $el if range.collapsed
    $el.before range.extractContents()

  save: (range = @range()) ->
    return if @_selectionSaved

    endRange = range.cloneRange()
    endRange.collapse(false)

    startCaret = $('<span/>').addClass('simditor-caret-start')
    endCaret = $('<span/>').addClass('simditor-caret-end')

    endRange.insertNode(endCaret[0])
    range.insertNode(startCaret[0])

    @clear()
    @_selectionSaved = true

  restore: ->
    return false unless @_selectionSaved

    startCaret = @editor.body.find('.simditor-caret-start')
    endCaret = @editor.body.find('.simditor-caret-end')

    if startCaret.length and endCaret.length
      startContainer = startCaret.parent()
      startOffset = startContainer.contents().index(startCaret)
      endContainer = endCaret.parent()
      endOffset = endContainer.contents().index(endCaret)

      if startContainer[0] == endContainer[0]
        endOffset -= 1

      range = document.createRange()
      range.setStart(startContainer.get(0), startOffset)
      range.setEnd(endContainer.get(0), endOffset)

      startCaret.remove()
      endCaret.remove()
      @range range
    else
      startCaret.remove()
      endCaret.remove()

    @_selectionSaved = false
    range
