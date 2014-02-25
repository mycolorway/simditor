
class Selection extends Plugin

  @className: 'Selection'

  constructor: (args...) ->
    super args...
    @sel = document.getSelection()
    @editor = @widget

  _init: ->

  clear: ->
    @sel.removeAllRanges()

  getRange: ->
    if !@editor.inputManager.focused or !@sel.rangeCount
      return null

    return @sel.getRangeAt 0

  selectRange: (range) ->
    @sel.removeAllRanges()
    @sel.addRange(range)

  rangeAtEndOf: (node, range = @getRange()) ->
    return unless range? and range.collapsed

    node = $(node)[0]
    endNode = range.endContainer
    endNodeLength = @editor.util.getNodeLength endNode
    #node.normalize()
    
    if !(range.endOffset == endNodeLength - 1 and $(endNode).contents().last().is('br')) and range.endOffset != endNodeLength
      return false

    if node == endNode
      return true
    else if !$.contains(node, endNode)
      return false

    result = true
    $(endNode).parentsUntil(node).addBack().each (i, n) =>
      nodes = $(n).parent().contents().filter ->
        !(this.nodeType == 3 && !this.nodeValue)
      $lastChild = nodes.last()
      unless $lastChild.get(0) == n or ($lastChild.is('br') and $lastChild.prev().get(0) == n)
        result = false
        return false

    result

  rangeAtStartOf: (node, range = @getRange()) ->
    return unless range? and range.collapsed

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
    range.collapse(false)
    @selectRange range

  setRangeBefore: (node, range = @getRange()) ->
    return unless range?

    node = $(node)[0]
    range.setEndBefore node
    range.collapse(false)
    @selectRange range

  setRangeAtStartOf: (node, range = @getRange()) ->
    node = $(node).get(0)
    range.setEnd(node, 0)
    range.collapse(false)
    @selectRange range

  setRangeAtEndOf: (node, range = @getRange()) ->
    $node = $(node)
    node = $node.get(0)

    if $node.is('pre')
      contents = $node.contents()
      if contents.length > 0
        lastChild = contents.last()
        lastText = lastChild.text()
        if lastText.charAt(lastText.length - 1) is '\n'
          range.setEnd(lastChild[0], @editor.util.getNodeLength(lastChild[0]) - 1)
        else
          range.setEnd(lastChild[0], @editor.util.getNodeLength(lastChild[0]))
      else
        range.setEnd(node, 0)
    else
      nodeLength = @editor.util.getNodeLength node
      nodeLength -= 1 if node.nodeType != 3 and nodeLength > 0 and $(node).contents().last().is('br')
      range.setEnd(node, nodeLength)

    range.collapse(false)
    @selectRange range

  deleteRangeContents: (range = @getRange()) ->
    range.deleteContents()

  breakBlockEl: (el, range = @getRange()) ->
    $el = $(el)
    return $el unless range.collapsed
    range.setStartBefore $el.get(0)
    return $el if range.collapsed
    $el.before range.extractContents()

  save: () ->
    return if @_selectionSaved

    range = @getRange()
    startCaret = $('<span/>').addClass('simditor-caret-start')
    endCaret = $('<span/>').addClass('simditor-caret-end')

    range.insertNode(startCaret[0])
    range.collapse(false)
    range.insertNode(endCaret[0])

    @sel.removeAllRanges()
    @_selectionSaved = true

  restore: () ->
    return false unless @_selectionSaved

    startCaret = @editor.body.find('.simditor-caret-start')
    endCaret = @editor.body.find('.simditor-caret-end')

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




class Formatter extends Plugin

  @className: 'Formatter'

  constructor: (args...) ->
    super args...
    @editor = @widget

  _init: ->
    @editor.body.on 'click', 'a', (e) =>
      false

  _allowedTags: ['a', 'img', 'b', 'strong', 'i', 'u', 'p', 'ul', 'ol', 'li', 'blockquote', 'pre', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6']

  _allowedAttributes:
    img: ['src', 'alt', 'width', 'height', 'data-origin-src', 'data-origin-size', 'data-origin-name']
    a: ['href', 'target']
    pre: ['data-lang']

  decorate: ($el = @editor.body) ->
    @editor.trigger 'decorate', [$el]

  undecorate: ($el = @editor.body.clone()) ->
    @editor.trigger 'undecorate', [$el]
    $.trim $el.html()

  autolink: ($el = @editor.body) ->
    linkNodes = []

    findLinkNode = ($parentNode) ->
      $parentNode.contents().each (i, node) ->
        $node = $(node)
        if $node.is('a') or $node.closest('a', $el).length
          return

        if $node.contents().length
          findLinkNode $node
        else if text = $node.text() and /https?:\/\/|www\./ig.test(text)
          linkNodes.push $node

    findLinkNode $el

    re = /(https?:\/\/|www\.)[\w\-\.\?&=\/#%]+/ig
    for $node in linkNodes
      text = $node.text();
      replaceEls = [];
      match = null;
      lastIndex = 0;

      while (match = re.exec(text)) != null
        replaceEls.push document.createTextNode(text.substring(lastIndex, match.index))
        lastIndex = re.lastIndex
        uri = if /^(http(s)?:\/\/|\/)/.test(match[0]) then match[0] else 'http://' + match[0]
        replaceEls.push $('<a href="' + uri + '" rel="nofollow">' + match[0] + '</a>')[0]

      replaceEls.push document.createTextNode(text.substring(lastIndex))
      $node.replaceWith $(replaceEls)

    $el

  # make sure the direct children is block node
  format: ($el = @editor.body) ->
    if $el.is ':empty'
      $el.append '<p>' + @editor.util.phBr + '</p>'
      return $el

    @cleanNode(n, true) for n in $el.contents()

    for node in $el.contents()
      if @editor.util.isBlockNode(node) or $(node).is('img')
        blockNode = null
      else
        blockNode = $('<p/>').insertBefore(node) unless blockNode?
        blockNode.append(node)

    $el

  cleanNode: (node, recursive) ->
    $node = $(node)

    if $node[0].nodeType == 3
      return

    contents = $node.contents()
    isDecoration = $node.is('[class^="simditor-"]')

    if $node.is(@_allowedTags.join(',')) or isDecoration
      # img inside a is not allowed
      if $node.is('a') and $node.find('img').length > 0
        contents.first().unwrap()

      # Clean attributes except `src` `alt` on `img` tag and `href` `target` on `a` tag
      unless isDecoration
        allowedAttributes = @_allowedAttributes[$node[0].tagName.toLowerCase()]
        for attr in $.makeArray($node[0].attributes)
            $node.removeAttr(attr.name) unless allowedAttributes? and attr.name in allowedAttributes
    else if $node[0].nodeType == 1 and !$node.is ':empty'
      #$('<p/>').append(contents)
        #.insertBefore($node)
      contents.first().unwrap()
    else
      $node.remove()
      contents = null

    @cleanNode(n, true) for n in contents if recursive and contents?
    null

  clearHtml: (html, lineBreak = true) ->
    container = $('<div/>').append(html)
    result = ''

    container.contents().each (i, node) =>
      if node.nodeType == 3
        result += node.nodeValue
      else if node.nodeType == 1
        $node = $(node)
        contents = $node.contents()
        result += @clearHtml contents if contents.length > 0
        if lineBreak and $node.is 'p, div, li, tr, pre, address, artticle, aside, dd, figcaption, footer, h1, h2, h3, h4, h5, h6, header'
          result += '\n'

    result




class InputManager extends Plugin

  @className: 'InputManager'

  opts:
    tabIndent: true

  constructor: (args...) ->
    super args...
    @editor = @widget

  _modifierKeys: [16, 17, 18, 91, 93]

  _arrowKeys: [37..40]

  _init: ->
    @_pasteArea = $('<div/>')
      .css({
        width: '1px',
        height: '1px',
        overflow: 'hidden',
        position: 'fixed',
        right: '0',
        bottom: '100px'
      })
      .attr({
        tabIndex: '-1',
        contentEditable: true
      })
      .addClass('simditor-paste-area')
      .appendTo(@editor.el)

    @editor.on 'valuechanged', =>
      # make sure each code block and img has a p following it
      @editor.body.find('pre, .simditor-image').each (i, el) =>
        $el = $(el)
        if ($el.parent().is('blockquote') or $el.parent()[0] == @editor.body[0]) and $el.next().length == 0
          $('<p/>').append(@editor.util.phBr)
            .insertAfter($el)

    @editor.body.on('keydown', $.proxy(@_onKeyDown, @))
      .on('keypress', $.proxy(@_onKeyPress, @))
      .on('keyup', $.proxy(@_onKeyUp, @))
      .on('mouseup', $.proxy(@_onMouseUp, @))
      .on('focus', $.proxy(@_onFocus, @))
      .on('blur', $.proxy(@_onBlur, @))
      .on('paste', $.proxy(@_onPaste, @))

    if @editor.textarea.attr 'autofocus'
      setTimeout =>
        @editor.focus()
      , 0

  _onFocus: (e) ->
    @editor.el.addClass('focus')
      .removeClass('error')
    @focused = true

    @editor.body.find('.selected').removeClass('selected')

    setTimeout =>
      @editor.triggerHandler 'focus'
      @editor.trigger 'selectionchanged'
    , 0

  _onBlur: (e) ->
    @editor.el.removeClass 'focus'
    @editor.sync()
    @focused = false

    @editor.triggerHandler 'blur'

  _onMouseUp: (e) ->
    return if $(e.target).is('img, .simditor-image')
    @editor.trigger 'selectionchanged'

  _onKeyDown: (e) ->
    if @editor.triggerHandler(e) == false
      return false

    if e.which in @_modifierKeys or e.which in @_arrowKeys
      return

    metaKey = @editor.util.metaKey e
    $blockEl = @editor.util.closestBlockEl()

    # paste shortcut
    return if metaKey and e.which == 86

    # handle predefined shortcuts
    shortcutKey = @editor.util.getShortcutKey e
    if @_shortcuts[shortcutKey]
      @_shortcuts[shortcutKey].call(this, e)
      return false

    # Check the condictional handlers
    if e.which of @_inputHandlers
      result = null
      @editor.util.traverseUp (node) =>
        return unless node.nodeType == 1
        handler = @_inputHandlers[e.which]?[node.tagName.toLowerCase()]
        result = handler?.call(@, e, $(node))
        !result
      if result
        @editor.trigger 'valuechanged'
        @editor.trigger 'selectionchanged'
        return false

    # safari doesn't support shift + enter default behavior
    if @editor.util.browser.safari and e.which == 13 and e.shiftKey
      $br = $('<br/>')

      if @editor.selection.rangeAtEndOf $blockEl
        @editor.selection.insertNode $br
        @editor.selection.insertNode $('<br/>')
        @editor.selection.setRangeBefore $br
      else
        @editor.selection.insertNode $br

      @editor.trigger 'valuechanged'
      @editor.trigger 'selectionchanged'
      return false

    # Remove hr node
    if e.which == 8
      $prevBlockEl = $blockEl.prev()
      if $prevBlockEl.is 'hr' and @editor.selection.rangeAtStartOf $blockEl
        # TODO: need to test on IE
        $prevBlockEl.remove()
        @editor.trigger 'valuechanged'
        @editor.trigger 'selectionchanged'
        return false

    # Tab to indent
    if e.which == 9 and (@opts.tabIndent or $blockEl.is 'pre') and !$blockEl.is('li')
      spaces = if $blockEl.is 'pre' then '\u00A0\u00A0' else '\u00A0\u00A0\u00A0\u00A0'
      spaceNode = document.createTextNode spaces
      @editor.selection.insertNode spaceNode
      @editor.trigger 'valuechanged'
      @editor.trigger 'selectionchanged'
      return false

    if @_typing
      clearTimeout @_typing if @_typing != true
      @_typing = setTimeout =>
        @editor.trigger 'valuechanged'
        @editor.trigger 'selectionchanged'
        @_typing = false
      , 200
    else
      setTimeout =>
        @editor.trigger 'valuechanged'
        @editor.trigger 'selectionchanged'
      , 10
      @_typing = true

    null

  _onKeyPress: (e) ->
    if @editor.triggerHandler(e) == false
      return false
    
    # input hooks are limited in a single line
    @_hookStack.length = 0 if e.which == 13

    # check the input hooks
    if e.which == 32
      cmd = @_hookStack.join ''
      @_hookStack.length = 0

      for hook in @_inputHooks
        if (hook.cmd instanceof RegExp and hook.cmd.test(cmd)) or hook.cmd == cmd
          hook.callback(e, hook, cmd)
          break
    else if @_hookKeyMap[e.which]
      @_hookStack.push @_hookKeyMap[e.which]
      @_hookStack.shift() if @_hookStack.length > 10

  _onKeyUp: (e) ->
    if @editor.triggerHandler(e) == false
      return false

    if e.which in @_arrowKeys
      @editor.trigger 'selectionchanged'
      return

    if e.which == 8 and @editor.body.is ':empty'
      p = $('<p/>').append(@editor.util.phBr)
        .appendTo(@editor.body)
      @editor.selection.setRangeAtStartOf p
      return

  _onPaste: (e) ->
    if @editor.triggerHandler(e) == false
      return false

    $blockEl = @editor.util.closestBlockEl()
    codePaste = $blockEl.is 'pre'
    @editor.selection.deleteRangeContents()
    @editor.selection.save()

    @_pasteArea.focus()

    setTimeout =>
      if @_pasteArea.is(':empty')
        pasteContent = null
      else if codePaste
        pasteContent = @editor.formatter.clearHtml @_pasteArea.html()
      else
        pasteContent = $('<div/>').append(@_pasteArea.contents())
        @editor.formatter.format pasteContent
        @editor.formatter.decorate pasteContent
        pasteContent = pasteContent.contents()

      @_pasteArea.empty()
      range = @editor.selection.restore()

      if !pasteContent
        return
      else if codePaste
        node = document.createTextNode(pasteContent)
        @editor.selection.insertNode node, range
      else if pasteContent.length < 1
        return
      else if pasteContent.length == 1 and pasteContent.is('p')
        children = pasteContent.contents()
        range.insertNode node for node in children
        @editor.selection.setRangeAfter children.last()
      else
        $blockEl = $blockEl.parent() if $blockEl.is 'li'

        if @editor.selection.rangeAtStartOf($blockEl, range)
          insertPosition = 'before'
        else if @editor.selection.rangeAtEndOf($blockEl, range)
          insertPosition = 'after'
        else
          @editor.selection.breakBlockEl($blockEl, range)
          insertPosition = 'before'

        $blockEl[insertPosition](pasteContent)
        @editor.selection.setRangeAtEndOf(pasteContent.last(), range)

      @editor.trigger 'valuechanged'
      @editor.trigger 'selectionchanged'
    , 10

  # handlers which will be called when specific key is pressed in specific node
  _inputHandlers:
    13: # enter

      # press enter in a empty list item
      li: (e, $node) ->
        return unless @editor.util.isEmptyNode $node
        e.preventDefault()
        range = @editor.selection.getRange()

        if !$node.next('li').length
          listEl = $node.parent()
          newBlockEl = $('<p/>').append(@editor.util.phBr).insertAfter(listEl)

          if $node.siblings('li').length
            $node.remove()
          else
            listEl.remove()

          range.setEnd(newBlockEl[0], 0)
        else
          newLi = $('<li/>').append(@editor.util.phBr).insertAfter($node)
          range.setEnd(newLi[0], 0)

        range.collapse(false)
        @editor.selection.selectRange(range)
        true

      # press enter in a code block: insert \n instead of br
      pre: (e, $node) ->
        e.preventDefault()
        range = @editor.selection.getRange()
        breakNode = null

        range.deleteContents()

        if !@editor.util.browser.msie && @editor.selection.rangeAtEndOf $node
          breakNode = document.createTextNode('\n\n')
          range.insertNode breakNode
          range.setEnd breakNode, 1
        else
          breakNode = document.createTextNode('\n')
          range.insertNode breakNode
          range.setStartAfter breakNode

        range.collapse(false)
        @editor.selection.selectRange range
        true

      # press enter in the last paragraph of blockquote, just leave the block quote
      blockquote: (e, $node) ->
        $closestBlock = @editor.util.closestBlockEl()
        return unless $closestBlock.is('p') and !$closestBlock.next().length and @editor.util.isEmptyNode $closestBlock
        $node.after $closestBlock
        @editor.selection.setRangeAtStartOf $closestBlock
        true

    8: # backspace
      pre: (e, $node) ->
        return unless @editor.selection.rangeAtStartOf $node
        codeStr = $node.html().replace('\n', '<br/>')
        $newNode = $('<p/>').append(codeStr || @editor.util.phBr).insertAfter $node
        $node.remove()
        @editor.selection.setRangeAtStartOf $newNode
        true

      blockquote: (e, $node) ->
        return unless @editor.selection.rangeAtStartOf $node
        $firstChild = $node.children().first().unwrap()
        @editor.selection.setRangeAtStartOf $firstChild
        true

    9: #tab
      li: (e, $node) ->
        if e.shiftKey
          $parent = $node.parent()
          $parentLi = $parent.parent('li')
          return true if $parentLi.length < 0

          @editor.selection.save()

          if $node.next('li').length > 0
            $('<' + $parent[0].tagName + '/>')
              .append($node.nextAll('li'))
              .appendTo($node)

          $node.insertAfter $parentLi
          $parent.remove() if $parent.children('li').length < 1
          @editor.selection.restore()
        else
          $parentLi = $node.prev('li')
          return true if $parentLi.length < 1

          @editor.selection.save()
          tagName = $node.parent()[0].tagName
          $childList = $parentLi.children('ul, ol')

          if $childList.length > 0
            $childList.append $node
          else
            $('<' + tagName + '/>')
              .append($node)
              .appendTo($parentLi)

          @editor.selection.restore()

        true

  # a hook will be triggered when specific string was typed
  _inputHooks: []

  _hookKeyMap: {}

  _hookStack: []

  addInputHook: (hookOpt) ->
    $.extend(@_hookKeyMap, hookOpt.key)
    @_inputHooks.push hookOpt

  _shortcuts:
    # meta + enter: submit form
    'cmd+13': (e) ->
      @editor.el.closest('form')
        .find('button:submit')
        .click()

  addShortcut: (keys, handler) ->
    @_shortcuts[keys] = $.proxy(handler, this)





class UndoManager extends Plugin

  @className: 'UndoManager'

  _stack: []

  _index: -1

  _capacity: 50

  _timer: null

  constructor: (args...) ->
    super args...
    @editor = @widget

  _init: ->
    @editor.inputManager.addShortcut 'cmd+90', (e) =>
      @undo()

    @editor.inputManager.addShortcut 'shift+cmd+90', (e) =>
      @redo()

    @editor.on 'valuechanged', (e, src) =>
      return if src == 'undo'

      if @_timer
        clearTimeout @_timer
        @_timer = null

      @_timer = setTimeout =>
        @_pushUndoState()
      , 200

    #@_pushUndoState()

  _pushUndoState: ->
    if @_stack.length and @_index > -1
      currentState = @_stack[@_index]

    html = @editor.body.html()
    return if currentState and currentState.html == html

    @_index += 1
    @_stack.length = @_index

    @_stack.push
      html: html
      caret: @caretPosition()

    if @_stack.length > @_capacity
      @_stack.shift()
      @_index -= 1

  undo: ->
    return if @_index < 1 or @_stack.length < 2

    @editor.hidePopover()

    @_index -= 1

    state = @_stack[@_index]
    @editor.body.html state.html
    @caretPosition state.caret
    @editor.sync()

    @editor.trigger 'valuechanged', ['undo']
    @editor.trigger 'selectionchanged', ['undo']

  redo: ->
    return if @_index < 0 or @_stack.length < @_index + 2

    @editor.hidePopover()

    @_index += 1

    state = @_stack[@_index]
    @editor.body.html state.html
    @caretPosition state.caret
    @editor.sync()

    @editor.trigger 'valuechanged', ['undo']
    @editor.trigger 'selectionchanged', ['undo']

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
        offset += @editor.util.getNodeLength prevNode
        prevNode = prevNode.previousSibling
    else
      offset = @_getNodeOffset(node, offset)

    position = []
    position.unshift offset
    @editor.util.traverseUp (n) =>
      position.unshift @_getNodeOffset(n)
    , node

    position

  _getNodeByPosition: (position) ->
    node = @editor.body[0]

    for offset in position[0...position.length - 1]
      childNodes = node.childNodes
      if offset > childNodes.length - 1
        node = null
        break
      node = childNodes[offset]

    node

  caretPosition: (caret) ->
    # calculate current caret state
    if !caret
      range = @editor.selection.getRange()
      return {} unless @editor.inputManager.focused and range?

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
      @editor.body.focus() unless @editor.inputManager.focused

      unless caret.start
        @editor.body.blur()
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

      @editor.selection.selectRange range






class Util extends Plugin

  @className: 'Util'

  constructor: (args...) ->
    super args...
    @phBr = '' if @browser.msie
    @editor = @widget

  _init: ->

  phBr: '<br/>'

  os: (->
    if /Mac/.test navigator.appVersion
      mac: true
    else if /Linux/.test navigator.appVersion
      linux: true
    else if /Win/.test navigator.appVersion
      win: true
    else if /X11/.test navigator.appVersion
      unix: true
    else
      {}
  )()

  browser: (->
    ua = navigator.userAgent
    ie = /(msie|trident)/i.test(ua)
    chrome = /chrome|crios/i.test(ua)
    safari = /safari/i.test(ua) && !chrome
    firefox = /firefox/i.test(ua)

    if ie
      msie: true
      version: ua.match(/(msie |rv:)(\d+(\.\d+)?)/i)[2]
    else if chrome
      webkit: true
      chrome: true
      version: ua.match(/(?:chrome|crios)\/(\d+(\.\d+)?)/i)[1]
    else if safari
      webkit: true
      safari: true
      version: ua.match(/version\/(\d+(\.\d+)?)/i)[1]
    else if firefox
      mozilla: true
      firefox: true
      version: ua.match(/firefox\/(\d+(\.\d+)?)/i)[1]
    else
      {}
  )()

  metaKey: (e) ->
    isMac = /Mac/.test navigator.userAgent
    if isMac then e.metaKey else e.ctrlKey

  isEmptyNode: (node) ->
    $node = $(node)
    !$node.text() and !$node.find(':not(br)').length

  isBlockNode: (node) ->
    node = $(node)[0]
    if !node or node.nodeType == 3
      return false

    /^(div|p|ul|ol|li|blockquote|hr|pre|h1|h2|h3|h4|h5|h6|table)$/.test node.nodeName.toLowerCase()

  closestBlockEl: (node) ->
    unless node?
      range = @editor.selection.getRange()
      node = range?.commonAncestorContainer

    $node = $(node)

    return null unless $node.length

    blockEl = $node.parentsUntil(@editor.body).addBack()
    blockEl = blockEl.filter (i) =>
      @isBlockNode blockEl.eq(i)

    if blockEl.length then blockEl.last() else null

  furthestNode: (node, filter) ->
    unless node?
      range = @editor.selection.getRange()
      node = range?.commonAncestorContainer

    $node = $(node)

    return null unless $node.length

    blockEl = $node.parentsUntil(@editor.body).addBack()
    blockEl = blockEl.filter (i) =>
      $n = blockEl.eq(i)
      if $.isFunction filter
        return filter $n
      else
        return $n.is(filter)

    if blockEl.length then blockEl.first() else null


  furthestBlockEl: (node) ->
    @furthestNode(node, @isBlockNode)
    #unless node?
      #range = @editor.selection.getRange()
      #node = range?.commonAncestorContainer

    #$node = $(node)

    #return null unless $node.length

    #blockEl = $node.parentsUntil(@editor.body).addBack()
    #blockEl = blockEl.filter (i) =>
      #@isBlockNode blockEl.eq(i)

    #if blockEl.length then blockEl.first() else null

  getNodeLength: (node) ->
    switch node.nodeType
      when 7, 10 then 0
      when 3, 8 then node.length
      else node.childNodes.length


  traverseUp:(callback, node) ->
    unless node?
      range = @editor.selection.getRange()
      node = range?.commonAncestorContainer

    if !node? or !$.contains(@editor.body[0], node)
      return false

    nodes = $(node).parentsUntil(@editor.body).get()
    nodes.unshift node
    for n in nodes
      result = callback n
      break if result == false

  getShortcutKey: (e) ->
    shortcutName = []
    shortcutName.push 'shift' if e.shiftKey
    shortcutName.push 'ctrl' if e.ctrlKey
    shortcutName.push 'alt' if e.altKey
    shortcutName.push 'cmd' if e.metaKey
    shortcutName.push e.which
    shortcutName.join '+'




class Toolbar extends Plugin

  @className: 'Toolbar'

  opts:
    toolbar: true
    toolbarFloat: true

  _tpl: 
    wrapper: '<div class="simditor-toolbar"><ul></ul></div>'
    separator: '<li><span class="separator"></span></li>'

  constructor: (args...) ->
    super args...
    @editor = @widget

  _init: ->
    return unless @opts.toolbar

    unless $.isArray @opts.toolbar
      @opts.toolbar = ['bold', 'italic', 'underline', '|', 'ol', 'ul', 'blockquote', 'code', '|', 'link', 'image']

    @_render()
    
    @list.on 'click', (e) =>
      false

    @wrapper.on 'mousedown', (e) =>
      @list.find('.menu-on').removeClass('.menu-on')

    $(document).on 'mousedown.simditor', (e) =>
      @list.find('.menu-on').removeClass('.menu-on')

    if @opts.toolbarFloat
      $(window).on 'scroll.simditor-' + @editor.id, (e) =>
        topEdge = @editor.wrapper.offset().top
        bottomEdge = topEdge + @editor.wrapper.outerHeight() - 100
        scrollTop = $(document).scrollTop()
        top = 0

        if scrollTop <= topEdge
          top = 0
          @wrapper.removeClass('floating')
        else if bottomEdge > scrollTop > topEdge
          top = scrollTop - topEdge
          @wrapper.addClass('floating')
        else
          top = bottomEdge - topEdge
          @wrapper.addClass('floating')

        @wrapper.css 'top', top

    @editor.on 'selectionchanged', =>
      @toolbarStatus()

    @editor.on 'destroy', =>
      @_buttons.length = 0


  _render: ->
    @wrapper = $(@_tpl.wrapper).prependTo(@editor.wrapper)
    @list = @wrapper.find('ul')
    @editor.wrapper.addClass('toolbar-enabled')

    for name in @opts.toolbar
      if name == '|'
        $(@_tpl.separator).appendTo @list
        continue

      unless @constructor.buttons[name]
        throw new Error 'simditor: invalid toolbar button "' + name + '"'
        continue
      
      @_buttons.push new @constructor.buttons[name](@editor)

  toolbarStatus: (name) ->
    return unless @editor.inputManager.focused

    buttons = @_buttons[..]
    @editor.util.traverseUp (node) =>
      removeButtons = []
      for button, i in buttons
        continue if name? and button.name isnt name
        removeButtons.push button if !button.status or button.status($(node)) is true

      for button in removeButtons
        i = $.inArray(button, buttons)
        buttons.splice(i, 1)
      return false if buttons.length == 0

    #button.setActive false for button in buttons unless success

  # button instances
  _buttons: []

  @addButton: (btn) ->
    @buttons[btn::name] = btn

  @buttons: {}




class Simditor extends Widget
  @connect Util
  @connect UndoManager
  @connect InputManager
  @connect Formatter
  @connect Selection
  @connect Toolbar

  @count: 0

  opts:
    textarea: null
    placeholder: false
    defaultImage: 'images/image.png'
    params: null
    upload: true

  _init: ->
    @textarea = $(@opts.textarea);
    @opts.placeholder = @opts.placeholder ? @textarea.attr('placeholder')

    unless @textarea.length
      throw new Error 'simditor: param textarea is required.'
      return

    editor = @textarea.data 'simditor'
    if editor?
      editor.destroy()

    @id = ++ Simditor.count
    @_render()

    if @opts.upload and Uploader
      uploadOpts = if typeof @opts.upload == 'object' then @opts.upload else {}
      @uploader = new Uploader(uploadOpts)

    form = @textarea.closest 'form'
    if form.length
      form.on 'submit.simditor-' + @id, =>
        @sync()
      form.on 'reset.simditor-' + @id, =>
        @setValue ''

    @setValue @textarea.val() ? ''

    if @opts.placeholder
      @on 'valuechanged', =>
        @_placeholder()

    setTimeout =>
      @trigger 'valuechanged'
    , 0

    # Disable the resizing of `img` and `table`
    #if @browser.mozilla
      #document.execCommand "enableObjectResizing", false, "false"
      #document.execCommand "enableInlineTableEditing", false, "false"

  _tpl:"""
    <div class="simditor">
      <div class="simditor-wrapper">
        <div class="simditor-placeholder"></div>
        <div class="simditor-body" contenteditable="true">
        </div>
      </div>
    </div>
  """

  _render: ->
    @el = $(@_tpl).insertBefore @textarea
    @wrapper = @el.find '.simditor-wrapper'
    @body = @wrapper.find '.simditor-body'
    @placeholderEl = @wrapper.find('.simditor-placeholder').append(@opts.placeholder)

    @el.append(@textarea)
      .data 'simditor', this
    @textarea.data('simditor', this)
      .hide()
      .blur()
    @body.attr 'tabindex', @textarea.attr('tabindex')

    if @util.os.mac
      @el.addClass 'simditor-mac'
    else if @util.os.linux
      @el.addClass 'simditor-linux'

    if @opts.params
      for key, val of @opts.params
        $('<input/>', {
          type: 'hidden'
          name: key,
          value: val
        }).insertAfter(@textarea)

  _placeholder: ->
    children = @body.children()
    if children.length == 0 or (children.length == 1 and @util.isEmptyNode(children))
      @placeholderEl.show()
    else
      @placeholderEl.hide()

  setValue: (val) ->
    @textarea.val val
    @body.html val

    @formatter.format()
    @formatter.decorate()

  getValue: () ->
    @sync()

  sync: ->
    cloneBody = @body.clone()
    @formatter.format cloneBody

    # generate `a` tag automatically
    @formatter.autolink cloneBody

    # remove empty `p` tag at the end of content
    lastP = cloneBody.children().last 'p'
    while lastP.is('p') and !lastP.text() and !lastP.find('img').length
      emptyP = lastP
      lastP = lastP.prev 'p'
      emptyP.remove()

    val = @formatter.undecorate cloneBody
    @textarea.val val
    val

  focus: ->
    $blockEl = @body.find('p, li, pre, h1, h2, h3, h4, h5, h6, td').first()
    range = document.createRange()
    @selection.setRangeAtStartOf $blockEl, range
    @body.focus()

  blur: ->
    @body.blur()

  hidePopover: ->
    @wrapper.find('.simditor-popover').each (i, popover) =>
      popover = $(popover).data('popover')
      popover.hide() if popover.active

  destroy: ->
    @triggerHandler 'destroy'

    @textarea.closest('form')
      .off('.simditor .simditor-' + @id)

    @selection.clear()

    @textarea.insertBefore(@el)
      .hide()
      .val('')
      .removeData 'simditor'

    @el.remove()
    $(document).off '.simditor-' + @id
    $(window).off '.simditor-' + @id
    @off()


window.Simditor = Simditor


class Button extends Module

  _tpl:
    item: '<li><a tabindex="-1" unselectable="on" class="toolbar-item" href="javascript:;"><span></span></a></li>'
    menuWrapper: '<div class="toolbar-menu"></div>'
    menuItem: '<li><a tabindex="-1" unselectable="on" class="menu-item" href="javascript:;"><span></span></a></li>'
    separator: '<li><span class="separator"></span></li>'

  name: ''

  icon: ''

  title: ''

  text: ''

  htmlTag: ''

  disableTag: ''

  menu: false

  active: false

  disabled: false

  needFocus: true

  shortcut: null

  constructor: (@editor) ->
    @render()

    @el.on 'mousedown', (e) =>
      e.preventDefault()
      return if @el.hasClass('disabled') or (@needFocus and !@editor.inputManager.focused)

      if @menu
        @editor.toolbar.wrapper.toggleClass('menu-on')
      else
        @command()

    @editor.toolbar.list.on 'mousedown', 'a.menu-item', (e) =>
      e.preventDefault()
      btn = $(e.currentTarget)
      return if btn.hasClass 'disabled'

      @editor.toolbar.wrapper.removeClass('menu-on')
      param = btn.data('param')
      @command(param)

    @editor.on 'blur', =>
      @setActive false
      @setDisabled false

    if @shortcut?
      @editor.inputManager.addShortcut @shortcut, (e) =>
        @el.mousedown()

  render: ->
    @wrapper = $(@_tpl.item).appendTo @editor.toolbar.list
    @el = @wrapper.find 'a.toolbar-item'

    @el.attr('title', @title)
      .addClass('toolbar-item-' + @name)
      .data('button', this)

    @el.find('span')
      .addClass(if @icon then 'fa fa-' + @icon else '')
      .text(@text)

    return unless @menu

    @menuWrapper = $(@_tpl.menuWrapper).appendTo(@wrapper)
    @renderMenu()

  renderMenu: ->
    return unless $.isArray @menu

    @menuEl = $('<ul/>').appendTo @menuWrapper
    for menuItem in @menu
      if menuItem == '|'
        $(@_tpl.separator).appendTo @menuEl
        continue

      $menuItemEl = $(@_tpl.menuItem).appendTo @menuEl
      $menuBtntnEl = $menuItemEl.find('a.menu-item')
        .attr(
          'title': menuItem.title
        )
        .addClass('menu-item-' + menuItem.name)
        .data('param', menuItem.param)
        .find('span')
        .text(menuItem.text)

  setActive: (active) ->
    @active = active
    @el.toggleClass('active', @active)

  setDisabled: (disabled) ->
    @disabled = disabled
    @el.toggleClass('disabled', @disabled)

  status: ($node) ->
    @setDisabled $node.is(@disableTag) if $node?
    return true if @disabled

    @setActive $node.is(@htmlTag) if $node?
    @active

  command: (param) ->


window.SimditorButton = Button


class Popover extends Module

  offset:
    top: 4
    left: 0

  target: null

  active: false

  constructor: (@editor) ->
    @el = $('<div class="simditor-popover"></div>')
      .appendTo(@editor.wrapper)
      .data('popover', @)
    @render()

    @editor.on 'blur.linkpopover', =>
      @target.addClass('selected') if @active and @target?

  render: ->

  show: ($target, position = 'bottom') ->
    return unless $target?
    @target = $target

    @el.siblings('.simditor-popover').each (i, el) =>
      popover = $(el).data('popover')
      popover.hide()

    if @active
      @refresh(position)
      @trigger 'popovershow'
    else
      @active = true

      @el.css({
        left: -9999
      }).show()

      setTimeout =>
        @refresh(position)
        @trigger 'popovershow'
      , 0

  hide: ->
    return unless @active
    @target.removeClass('selected') if @target
    @target = null
    @active = false
    @el.hide()
    @trigger 'popoverhide'

  refresh: (position = 'bottom') ->
    wrapperOffset = @editor.wrapper.offset()
    targetOffset = @target.offset()
    targetH = @target.outerHeight()

    if position is 'bottom'
      top = targetOffset.top - wrapperOffset.top + targetH
    else if position is 'top'
      top = targetOffset.top - wrapperOffset.top - @el.height()

    left = Math.min(targetOffset.left - wrapperOffset.left, @editor.wrapper.width() - @el.outerWidth() - 10)

    @el.css({
      top: top + @offset.top,
      left: left + @offset.left
    })

  destroy: () ->
    @target = null
    @active = false
    @editor.off('.linkpopover')
    @el.remove()


class BoldButton extends Button

  name: 'bold'

  icon: 'bold'

  title: '加粗文字'

  htmlTag: 'b, strong'

  disableTag: 'pre'

  shortcut: 'cmd+66'

  status: ($node) ->
    @setDisabled $node.is(@disableTag) if $node?
    return true if @disabled

    active = document.queryCommandState('bold') is true
    @setActive active
    active

  command: ->
    document.execCommand 'bold'
    @editor.trigger 'valuechanged'
    @editor.trigger 'selectionchanged'


Simditor.Toolbar.addButton(BoldButton)


class ItalicButton extends Button

  name: 'italic'

  icon: 'italic'

  title: '斜体文字'

  htmlTag: 'i'

  disableTag: 'pre'

  shortcut: 'cmd+73'

  status: ($node) ->
    @setDisabled $node.is(@disableTag) if $node?
    return @disabled if @disabled

    active = document.queryCommandState('italic') is true
    @setActive active
    active

  command: ->
    document.execCommand 'italic'
    @editor.trigger 'valuechanged'
    @editor.trigger 'selectionchanged'


Simditor.Toolbar.addButton(ItalicButton)



class UnderlineButton extends Button

  name: 'underline'

  icon: 'underline'

  title: '下划线文字'

  htmlTag: 'u'

  disableTag: 'pre'

  shortcut: 'cmd+85'

  status: ($node) ->
    @setDisabled $node.is(@disableTag) if $node?
    return @disabled if @disabled

    active = document.queryCommandState('underline') is true
    @setActive active
    active

  command: ->
    document.execCommand 'underline'
    @editor.trigger 'valuechanged'
    @editor.trigger 'selectionchanged'


Simditor.Toolbar.addButton(UnderlineButton)




class ListButton extends Button

  type: ''

  disableTag: 'pre'

  status: ($node) ->
    @setDisabled $node.is(@disableTag) if $node?
    return true if @disabled
    return @active unless $node?

    anotherType = if @type == 'ul' then 'ol' else 'ul'
    if $node.is anotherType
      @setActive false
      return true
    else
      @setActive $node.is(@htmlTag)
      return @active

  command: (param) ->
    range = @editor.selection.getRange()
    startNode = range.startContainer
    endNode = range.endContainer
    $startBlock = @editor.util.closestBlockEl(startNode)
    $endBlock = @editor.util.closestBlockEl(endNode)

    @editor.selection.save()

    range.setStartBefore $startBlock[0]
    range.setEndAfter $endBlock[0]

    if $startBlock.is('li') and $endBlock.is('li')
      $furthestStart = @editor.util.furthestNode $startBlock, 'ul, ol'
      $furthestEnd = @editor.util.furthestNode $endBlock, 'ul, ol'
      if $furthestStart.is $furthestEnd
        getListLevel = ($li) ->
          lvl = 1
          while !$li.parent().is $furthestStart
            lvl += 1
            $li = $li.parent()
          return lvl

        startLevel = getListLevel $startBlock
        endLevel = getListLevel $endBlock

        if startLevel > endLevel
          $parent = $endBlock.parent()
        else
          $parent = $startBlock.parent()

        range.setStartBefore $parent[0]
        range.setEndAfter $parent[0]
      else
        range.setStartBefore $furthestStart[0]
        range.setEndAfter $furthestEnd[0]

    $contents = $(range.extractContents())

    #if $breakedEl?
      #$contents.wrapInner('<' + $breakedEl[0].tagName + '/>')
      #if @editor.selection.rangeAtStartOf $breakedEl, range
        #range.setEndBefore($breakedEl[0])
        #range.collapse(false)
        #$breakedEl.remove() if $breakedEl.children().length < 1
      #else if @editor.selection.rangeAtEndOf $breakedEl, range
        #range.setEndAfter($breakedEl[0])
        #range.collapse(false)
      #else
        #$breakedEl = @editor.selection.breakBlockEl($breakedEl, range)
        #range.setEndBefore($breakedEl[0])
        #range.collapse(false)

    results = []
    $contents.children().each (i, el) =>
      converted = @_convertEl el
      for c in converted
        if results.length and results[results.length - 1].is(@type) and c.is(@type)
          results[results.length - 1].append(c.children())
        else
          results.push(c)

    range.insertNode node[0] for node in results.reverse()
    @editor.selection.restore()

    @editor.trigger 'valuechanged'
    @editor.trigger 'selectionchanged'

  _convertEl: (el) ->
    $el = $(el)
    results = []
    anotherType = if @type == 'ul' then 'ol' else 'ul'
    
    if $el.is @type
      $el.children('li').each (i, li) =>
        $li = $(li)
        $childList = $li.children('ul, ol').remove()
        block = $('<p/>').append($(li).html() || @editor.util.phBr)
        results.push block
        results.push $childList if $childList.length > 0
    else if $el.is anotherType
      block = $('<' + @type + '/>').append($el.html())
      results.push(block)
    else if $el.is 'blockquote'
      children = @_convertEl child for child in $el.children().get()
      $.merge results, children
    else if $el.is 'table'
      # TODO
    else
      block = $('<' + @type + '><li></li></' + @type + '>')
      block.find('li').append($el.html() || @editor.util.phBr)
      results.push(block)

    results


class OrderListButton extends ListButton
  type: 'ol'
  name: 'ol'
  title: '有序列表'
  icon: 'list-ol'
  htmlTag: 'ol'

class UnorderListButton extends ListButton
  type: 'ul'
  name: 'ul'
  title: '无序列表'
  icon: 'list-ul'
  htmlTag: 'ul'

Simditor.Toolbar.addButton(OrderListButton)
Simditor.Toolbar.addButton(UnorderListButton)



class BlockquoteButton extends Button

  name: 'blockquote'

  icon: 'quote-left'

  title: '引用'

  htmlTag: 'blockquote'

  disableTag: 'pre'

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
    @editor.trigger 'selectionchanged'

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



Simditor.Toolbar.addButton(BlockquoteButton)



class CodeButton extends Button

  name: 'code'

  icon: 'code'

  title: '插入代码'

  htmlTag: 'pre'

  disableTag: 'li'

  render: (args...) ->
    super args...
    @popover = new CodePopover(@editor)

  status: ($node) ->
    result = super $node

    if @active
      @popover.show($node)
    else if @editor.util.isBlockNode($node)
      @popover.hide()

    result

  command: ->
    range = @editor.selection.getRange()
    startNode = range.startContainer
    endNode = range.endContainer
    $startBlock = @editor.util.closestBlockEl(startNode)
    $endBlock = @editor.util.closestBlockEl(endNode)

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
    @editor.selection.setRangeAtEndOf results[0]

    @editor.trigger 'valuechanged'
    @editor.trigger 'selectionchanged'

  _convertEl: (el) ->
    $el = $(el)
    results = []

    if $el.is @htmlTag
      block = $('<p/>').append($el.html().replace('\n', '<br/>'))
      results.push block
    else
      codeStr = @editor.formatter.clearHtml($el)
      block = $('<' + @htmlTag + '/>').append(codeStr)
      results.push(block)

    results


class CodePopover extends Popover

  _tpl: """
    <div class="code-settings">
      <div class="settings-field">
        <select class="select-lang">
          <option value="-1">选择程序语言</option>
          <option value="c++">C++</option>
          <option value="css">CSS</option>
          <option value="coffeeScript">CoffeeScript</option>
          <option value="html">Html,XML</option>
          <option value="json">JSON</option>
          <option value="java">Java</option>
          <option value="js">JavaScript</option>
          <option value="markdown">Markdown</option>
          <option value="oc">Objective C</option>
          <option value="php">PHP</option>
          <option value="perl">Perl</option>
          <option value="python">Python</option>
          <option value="ruby">Ruby</option>
          <option value="sql">SQL</option>
        </select>
      </div>
    </div>
  """

  render: ->
    @el.addClass('code-popover')
      .append(@_tpl)
    @selectEl = @el.find '.select-lang'

    @selectEl.on 'change', (e) =>
      lang = @selectEl.val()
      oldLang = @target.attr('data-lang')
      @target.removeClass('lang-' + oldLang)
        .removeAttr('data-lang')

      if @lang isnt -1
        @target.addClass('lang-' + lang) 
        @target.attr('data-lang', lang)

      #range = document.createRange()
      #@editor.selection.setRangeAtEndOf(@target, range)
      #@editor.body.focus()

  show: (args...) ->
    super args...
    @lang = @target.attr('data-lang')
    @selectEl.val(@lang) if @lang?


Simditor.Toolbar.addButton(CodeButton)




class LinkButton extends Button

  name: 'link'

  icon: 'link'

  title: '插入链接'

  htmlTag: 'a'

  disableTag: 'pre'

  render: (args...) ->
    super args...
    @popover = new LinkPopover(@editor)

  status: ($node) ->
    result = super $node

    if @active
      @popover.show($node)
    else if @editor.util.isBlockNode($node)
      @popover.hide()

    result

  command: ->
    range = @editor.selection.getRange()

    if @active
      $link = $(range.commonAncestorContainer).closest('a')
      txtNode = document.createTextNode $link.text()
      $link.replaceWith txtNode
      range.selectNode txtNode
    else
      startNode = range.startContainer
      endNode = range.endContainer
      $startBlock = @editor.util.closestBlockEl(startNode)
      $endBlock = @editor.util.closestBlockEl(endNode)

      $contents = $(range.extractContents())
      $link = $('<a/>', {
        href: 'http://www.example.com',
        target: '_blank',
        text: @editor.formatter.clearHtml($contents.contents(), false) || '链接文字'
      })

      if $startBlock[0] == $endBlock[0]
        range.insertNode $link[0]
      else
        $newBlock = $('<p/>').append($link)
        range.insertNode $newBlock[0]

      range.selectNodeContents $link[0]

    @editor.selection.selectRange range

    @popover.one 'popovershow', =>
      @popover.textEl.focus()
      @popover.textEl[0].select()

    @editor.trigger 'valuechanged'
    @editor.trigger 'selectionchanged'


class LinkPopover extends Popover

  _tpl: """
    <div class="link-settings">
      <div class="settings-field">
        <label>文本</label>
        <input class="link-text" type="text"/>
        <a class="btn-unlink" href="javascript:;" title="取消链接"><span class="fa fa-unlink"></span></a>
      </div>
      <div class="settings-field">
        <label>链接</label>
        <input class="link-url" type="text"/>
      </div>
    </div>
  """

  render: ->
    @el.addClass('link-popover')
      .append(@_tpl)
    @textEl = @el.find '.link-text'
    @urlEl = @el.find '.link-url'
    @unlinkEl = @el.find '.btn-unlink'

    @textEl.on 'keyup', (e) =>
      return if e.which == 13
      @target.text @textEl.val()

    @urlEl.on 'keyup', (e) =>
      return if e.which == 13
      @target.attr 'href', @urlEl.val()

    $([@urlEl[0], @textEl[0]]).on 'keydown', (e) =>
      if e.which == 13 or e.which == 27 or (e.which == 9 and $(e.target).hasClass('link-url'))
        e.preventDefault()
        setTimeout =>
          range = document.createRange()
          @editor.selection.setRangeAfter @target, range
          @editor.body.focus()
          @hide()
          @editor.trigger 'valuechanged'
        , 0

    @unlinkEl.on 'click', (e) =>
      txtNode = document.createTextNode @target.text()
      @target.replaceWith txtNode
      @hide()

      range = document.createRange()
      @editor.selection.setRangeAfter txtNode, range
      @editor.body.focus() unless @editor.inputManager.focused

  show: (args...) ->
    super args...
    @textEl.val @target.text()
    @urlEl.val @target.attr('href')



Simditor.Toolbar.addButton(LinkButton)



class ImageButton extends Button

  _wrapperTpl: """
    <div class="simditor-image" contenteditable="false" tabindex="-1">
      <div class="simditor-image-resize-handle right"></div>
      <div class="simditor-image-resize-handle bottom"></div>
      <div class="simditor-image-resize-handle right-bottom"></div>
    </div>
  """

  name: 'image'

  icon: 'picture-o'

  title: '插入图片'

  htmlTag: 'img'

  disableTag: 'pre, a, b, strong, i, u, table'

  defaultImage: ''

  maxWidth: 0

  constructor: (args...) ->
    super args...

    @defaultImage = @editor.opts.defaultImage
    @maxWidth = @editor.wrapper.width()

    @editor.on 'decorate', (e, $el) =>
      $el.find('img').each (i, img) =>
        @decorate $(img)

    @editor.on 'undecorate', (e, $el) =>
      $el.find('img').each (i, img) =>
        @undecorate $(img)

    @editor.body.on 'mousedown', '.simditor-image', (e) =>
      $imgWrapper = $(e.currentTarget)

      if $imgWrapper.hasClass 'selected'
        @popover.srcEl.blur()
        @popover.hide()
        $imgWrapper.removeClass('selected')
      else
        @editor.body.blur()
        @editor.body.find('.simditor-image').removeClass('selected')
        $imgWrapper.addClass('selected').focus()
        $img = $imgWrapper.find('img')
        $imgWrapper.width $img.width()
        $imgWrapper.height $img.height()
        @popover.show $imgWrapper

      false

    @editor.body.on 'click', '.simditor-image', (e) =>
      false

    @editor.on 'selectionchanged', =>
      @popover.hide()

    @editor.body.on 'keydown', '.simditor-image', (e) =>
      return unless e.which == 8
      @popover.hide()
      $(e.currentTarget).remove()
      @editor.trigger 'valuechanged'
      return false

  render: (args...) ->
    super args...
    @popover = new ImagePopover(@)

  status: ($node) ->
    @setDisabled $node.is(@disableTag) if $node?
    return true if @disabled

  decorate: ($img) ->
    $wrapper = $img.parent('.simditor-image')
    return if $wrapper.length > 0

    $wrapper = $(@_wrapperTpl)
      .insertBefore($img)
      .prepend($img)

  undecorate: ($img) ->
    $wrapper = $img.parent('.simditor-image')
    return if $wrapper.length < 1

    $img.insertAfter $wrapper
    $wrapper.remove()

  loadImage: ($img, src, callback) ->
    $wrapper = $img.parent('.simditor-image')
    img = new Image()

    img.onload = =>
      if width > @maxWidth
        width = @maxWidth
        height = @maxWidth * img.height / img.width
      else
        width = img.width
        height = img.height

      $img.attr({
        src: src,
        width: width,
        height: height,
        'data-origin-name': src,
        'data-origin-src': src,
        'data-origin-size': width + ',' + height
      })

      $wrapper.width(width)
        .height(height)

      callback(true)

    img.onerror = =>
      callback(false)

    img.src = src

  command: ->
    range = @editor.selection.getRange()
    startNode = range.startContainer
    endNode = range.endContainer
    $startBlock = @editor.util.closestBlockEl(startNode)
    $endBlock = @editor.util.closestBlockEl(endNode)

    range.deleteContents()

    if $startBlock[0] == $endBlock[0] and $startBlock.is('p')
      if @editor.util.isEmptyNode $startBlock
        range.selectNode $startBlock[0]
        range.deleteContents()
      else if @editor.selection.rangeAtEndOf $startBlock, range
        range.setEndAfter($startBlock[0])
        range.collapse(false)
      else if @editor.selection.rangeAtStartOf $startBlock, range
        range.setEndBefore($startBlock[0])
        range.collapse(false)
      else
        $breakedEl = @editor.selection.breakBlockEl($startBlock, range)
        range.setEndBefore($breakedEl[0])
        range.collapse(false)

    $img = $('<img/>')
    range.insertNode $img[0]
    @decorate $img

    @loadImage $img, @defaultImage, =>
      @editor.trigger 'valuechanged'
      #@editor.trigger 'selectionchanged'
      $img.mousedown()

      @popover.one 'popovershow', =>
        @popover.srcEl.focus()
        @popover.srcEl[0].select()


class ImagePopover extends Popover

  _tpl: """
    <div class="link-settings">
      <div class="settings-field">
        <label>图片地址</label>
        <input class="image-src" type="text"/>
      </div>
    </div>
  """

  offset:
    top: 6
    left: -4

  constructor: (@button) ->
    super @button.editor

  render: ->
    @el.addClass('image-popover')
      .append(@_tpl)
    @srcEl = @el.find '.image-src'

    @srcEl.on 'keyup', (e) =>
      return if e.which == 13
      clearTimeout @timer if @timer

      @timer = setTimeout =>
        src = @srcEl.val()
        $img = @target.find('img')
        @button.loadImage $img, src, (success) =>
          return unless success
          @refresh()
          @editor.trigger 'valuechanged'

        @timer = null
      , 200

    @srcEl.on 'keydown', (e) =>
      if e.which == 13 or e.which == 27 or e.which == 9
        e.preventDefault()
        @srcEl.blur()
        @target.removeClass('selected')
        @hide()

  show: (args...) ->
    super args...
    $img = @target.find('img')
    @srcEl.val $img.attr('src')


Simditor.Toolbar.addButton(ImageButton)


