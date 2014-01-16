
Undo =

  _load: ->

  _init: ->
    @_undoStack = []
    @_undoIndex = -1
    @_undoCapacity = 50
    @_undoTimer = null

    @addShortcut 90, (e) =>
      if e.shiftKey
        @redo()
      else
        @undo()

    @on 'valuechanged', (e, src) =>
      return if src == 'undo' or !@focused

      if @_undoTimer
        clearTimeout @_undoTimer
        @_undoTimer = null

      @_undoTimer = setTimeout =>
        @_pushUndoState()
      , 300

    @body.on 'focus', =>
      if @_undoIndex < 0
        setTimeout =>
          @_pushUndoState()
        , 0

  _pushUndoState: ->
    if @_undoStack.length and @_undoIndex > -1
      currentState = @_undoStack[@_undoIndex]

    html = @body.html()
    return if currentState and currentState.html == html

    @_undoIndex += 1
    @_undoStack.length = @_undoIndex

    @_undoStack.push
      html: html
      caret: @caretPosition()

    if @_undoStack.length > @_undoCapacity
      @_undoStack.shift()
      @_undoIndex -= 1

    console.log @_undoStack

  undo: ->
    return if @_undoIndex < 1 or @_undoStack.length < 2

    @_undoIndex -= 1

    state = @_undoStack[@_undoIndex]
    @body.html state.html
    @sync()
    @caretPosition state.caret

    @trigger 'valuechanged', ['undo']
    @trigger 'selectionchanged', ['undo']

  redo: ->
    return if @_undoIndex < 0 or @_undoStack.length < @_undoIndex + 2

    @_undoIndex += 1

    state = @_undoStack[@_undoIndex]
    @body.html state.html
    @sync()
    @caretPosition state.caret

    @trigger 'valuechanged', ['undo']
    @trigger 'selectionchanged', ['undo']

  _getNodeOffset: (node, index) ->
    if index
      $parent = $(node)
    else
      $parent = $(node).parent()

    offset = 0
    merging = false
    $parent.contents().each (i, child) =>
      if index == i or node == child
        return false

      if child.nodeType == 3
        if !merging
          offset += 1
          merging = true
      else
        offset += 1
        merging = false

      null

    offset

  _getNodePosition: (node, offset) ->
    if node.nodeType == 3
      prevNode = node.previousSibling
      while prevNode and prevNode.nodeType == 3
        node = prevNode
        offset += @getNodeLength prevNode
        prevNode = prevNode.previousSibling
    else
      offset = @_getNodeOffset(node, offset)

    position = []
    position.unshift offset
    @traverseUp (n) =>
      position.unshift @_getNodeOffset(n)
    , node

    position

  _getNodeByPosition: (position) ->
    node = @body[0]

    for offset in position[0...position.length - 1]
      childNodes = node.childNodes
      if offset > childNodes.length - 1
        debugger
        node = null
        break
      node = childNodes[offset]

    node

  caretPosition: (caret) ->
    # calculate current caret state
    if !caret
      return {} unless @focused

      range = @getRange()
      caret =
        start: []
        end: null
        collapsed: true

      caret.start = @_getNodePosition(range.startContainer, range.startOffset)

      unless range.collapsed
        caret.end = @_getNodePosition(range.endContainer, range.endOffset)
        caret.collapsed = false

      return caret

    # restore caret state
    else
      @body.focus() unless @focused

      unless caret.start
        @body.blur()
        return

      startContainer = @_getNodeByPosition caret.start
      startOffset = caret.start[caret.start.length - 1]

      if caret.collapsed
        endContainer = startContainer
        endOffset = startOffset
      else
        endContainer = @_getNodeByPosition caret.end
        endOffset = caret.start[caret.start.length - 1]

      if !startContainer or !endContainer
        throw new Error 'simditor: invalid caret state'
        return

      range = document.createRange()
      range.setStart(startContainer, startOffset)
      range.setEnd(endContainer, endOffset)

      @selectRange range




