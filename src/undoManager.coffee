
class UndoManager extends SimpleModule

  @pluginName: 'UndoManager'

  _index: -1

  _capacity: 20

  _startPosition: null

  _endPosition: null

  _init: ->
    @editor = @_module
    @_stack = []

    if @editor.util.os.mac
      undoShortcut = 'cmd+z'
      redoShortcut = 'shift+cmd+z'
    else if @editor.util.os.win
      undoShortcut = 'ctrl+z'
      redoShortcut = 'ctrl+y'
    else
      undoShortcut = 'ctrl+z'
      redoShortcut = 'shift+ctrl+z'


    @editor.hotkeys.add undoShortcut, (e) =>
      e.preventDefault()
      @undo()
      false

    @editor.hotkeys.add redoShortcut, (e) =>
      e.preventDefault()
      @redo()
      false

    @throttledPushState = @editor.util.throttle =>
      @_pushUndoState()
    , 2000

    @editor.on 'valuechanged', (e, src) =>
      return if src == 'undo' or src == 'redo'
      @throttledPushState()

    @editor.on 'selectionchanged', (e) =>
      @resetCaretPosition()
      @update()

    @editor.on 'focus', (e) =>
      @_pushUndoState() if @_stack.length == 0

    @editor.on 'blur', (e) =>
      @resetCaretPosition()


  resetCaretPosition: ->
    @_startPosition = null
    @_endPosition = null

  startPosition: ->
    if @editor.selection._range
      @_startPosition ||= @_getPosition('start')

    @_startPosition

  endPosition: ->
    if @editor.selection._range
      @_endPosition ||= do =>
        range = @editor.selection.range()
        return @_startPosition if range.collapsed
        @_getPosition 'end'

    @_endPosition

  _pushUndoState: ->
    return if @editor.triggerHandler('pushundostate') == false

    caret = @caretPosition()
    return unless caret.start

    @_index += 1
    @_stack.length = @_index

    @_stack.push
      html: @editor.body.html()
      caret: @caretPosition()

    if @_stack.length > @_capacity
      @_stack.shift()
      @_index -= 1

  currentState: ->
    if @_stack.length and @_index > -1
      @_stack[@_index]
    else
      null

  undo: ->
    return if @_index < 1 or @_stack.length < 2

    @editor.hidePopover()

    @_index -= 1

    state = @_stack[@_index]
    @editor.body.get(0).innerHTML = state.html
    @caretPosition state.caret
    @editor.body.find('.selected').removeClass('selected')
    @editor.sync()

    @editor.trigger 'valuechanged', ['undo']

  redo: ->
    return if @_index < 0 or @_stack.length < @_index + 2

    @editor.hidePopover()

    @_index += 1

    state = @_stack[@_index]
    @editor.body.get(0).innerHTML = state.html
    @caretPosition state.caret
    @editor.body.find('.selected').removeClass('selected')
    @editor.sync()

    @editor.trigger 'valuechanged', ['redo']

  update: () ->
    currentState = @currentState()
    return unless currentState

    currentState.html = @editor.body.html()
    currentState.caret = @caretPosition()

  _getNodeOffset: (node, index) ->
    if $.isNumeric index
      $parent = $(node)
    else
      $parent = $(node).parent()

    offset = 0
    merging = false
    $parent.contents().each (i, child) ->
      return false if node == child or index == i == 0

      if child.nodeType == Node.TEXT_NODE
        if !merging and child.nodeValue.length > 0
          offset += 1
          merging = true
      else
        offset += 1
        merging = false

      return false if index - 1 == i
      null

    offset

  _getPosition: (type = 'start') ->
    range = @editor.selection.range()
    offset = range["#{type}Offset"]
    $nodes = @editor.selection["#{type}Nodes"]()
    node = $nodes.first()[0]

    # merge text nodes before startContainer/endContainer
    if node.nodeType == Node.TEXT_NODE
      prevNode = node.previousSibling
      while prevNode and prevNode.nodeType == Node.TEXT_NODE
        node = prevNode
        offset += @editor.util.getNodeLength prevNode
        prevNode = prevNode.previousSibling

      nodes = $nodes.get()
      nodes[0] = node
      $nodes = $ nodes
    else
      offset = @_getNodeOffset node, offset

    position = [offset]
    $nodes.each (i, node) =>
      position.unshift @_getNodeOffset(node)

    position

  _getNodeByPosition: (position) ->
    node = @editor.body[0]

    for offset, i in position[0...position.length - 1]
      childNodes = node.childNodes
      if offset > childNodes.length - 1
        # when pre is empty, the text node will be lost
        if i == position.length - 2 and $(node).is('pre:empty')
          child = document.createTextNode ''
          node.appendChild child
          childNodes = node.childNodes
        else
          node = null
          break
      node = childNodes[offset]

    node

  caretPosition: (caret) ->
    # calculate current caret state
    if !caret
      range = @editor.selection.range()
      caret = if @editor.inputManager.focused and range?
        start: @startPosition()
        end: @endPosition()
        collapsed: range.collapsed
      else
        {}

      return caret

    # restore caret state
    else
      return unless caret.start

      startContainer = @_getNodeByPosition caret.start
      startOffset = caret.start[caret.start.length - 1]

      if caret.collapsed
        endContainer = startContainer
        endOffset = startOffset
      else
        endContainer = @_getNodeByPosition caret.end
        endOffset = caret.start[caret.start.length - 1]

      if !startContainer or !endContainer
        console?.warn? 'simditor: invalid caret state'
        return

      range = document.createRange()
      range.setStart(startContainer, startOffset)
      range.setEnd(endContainer, endOffset)

      @editor.selection.range range
