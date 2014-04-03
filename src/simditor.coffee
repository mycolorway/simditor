
class Selection extends Plugin

  @className: 'Selection'

  constructor: (args...) ->
    super args...
    @sel = document.getSelection()
    @editor = @widget

  _init: ->

    #@editor.on 'selectionchanged focus', (e) =>
      #range = @editor.selection.getRange()
      #return unless range?
      #$container = $(range.commonAncestorContainer)

      #if range.collapsed and $container.is('.simditor-body') and @editor.util.isBlockNode($container.children())
        #@editor.blur()

  clear: ->
    try
      @sel.removeAllRanges()
    catch e

  getRange: ->
    if !@editor.inputManager.focused or !@sel.rangeCount
      return null

    return @sel.getRangeAt 0

  selectRange: (range) ->
    @clear()
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
        !(this != n && this.nodeType == 3 && !this.nodeValue)
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
        !(this != n && this.nodeType == 3 && !this.nodeValue)
      result = false unless nodes.first().get(0) == n

    result

  insertNode: (node, range = @getRange()) ->
    return unless range?

    node = $(node)[0]
    range.insertNode node
    @setRangeAfter node, range

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

    @clear()
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

      # firefox won't auto focus while applying new range
      @editor.body.focus() if @editor.util.browser.firefox
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

  _allowedTags: ['br', 'a', 'img', 'b', 'strong', 'i', 'u', 'p', 'ul', 'ol', 'li', 'blockquote', 'pre', 'h1', 'h2', 'h3', 'h4', 'hr']

  _allowedAttributes:
    img: ['src', 'alt', 'width', 'height', 'data-origin-src', 'data-origin-size', 'data-origin-name']
    a: ['href', 'target']
    pre: ['data-lang']
    p: ['data-indent']
    h1: ['data-indent']
    h2: ['data-indent']
    h3: ['data-indent']
    h4: ['data-indent']

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
        else if (text = $node.text()) and /https?:\/\/|www\./ig.test(text)
          linkNodes.push $node

    findLinkNode $el

    re = /(https?:\/\/|www\.)[\w\-\.\?&=\/#%:]+/ig
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
      $node = $(node)
      if $node.is('br')
        blockNode = null if blockNode?
        $node.remove()
      else if @editor.util.isBlockNode(node) or $node.is('img')
        if $node.is('li')
          if blockNode and blockNode.is('ul, ol')
            blockNode.append node
          else
            blockNode = $('<ul/>').insertBefore(node)
            blockNode.append node
        else
          blockNode = null
      else
        blockNode = $('<p/>').insertBefore(node) if !blockNode or blockNode.is('ul, ol')
        blockNode.append(node)

    $el

  cleanNode: (node, recursive) ->
    $node = $(node)

    if $node[0].nodeType == 3
      text = $node.text().replace(/(\r\n|\n|\r)/gm, '')
      textNode = document.createTextNode text
      $node.replaceWith textNode
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
      if $node.is('div, article, dl, header, footer, tr')
        $node.append('<br/>')
        contents.first().unwrap()
      else if $node.is 'table'
        $p = $('<p/>')
        $node.find('tr').each (i, tr) =>
          $p.append($(tr).text() + '<br/>')
        $node.replaceWith $p
        contents = null
      else if $node.is 'thead, tfoot'
        $node.remove()
        contents = null
      else if $node.is 'th'
        $td = $('<td/>').append $node.contents()
        $node.replaceWith $td
      else
        contents.first().unwrap()
    else
      $node.remove()
      contents = null

    @cleanNode(n, true) for n in contents if recursive and contents? and !$node.is('pre')
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
        if lineBreak and $node.is 'br, p, div, li, tr, pre, address, artticle, aside, dl, figcaption, footer, h1, h2, h3, h4, header'
          result += '\n'

    result

  # remove empty nodes and useless paragraph
  beautify: ($contents) ->
    uselessP = ($el) ->
      !!($el.is('p') and !$el.text() and $el.children(':not(br)').length < 1)

    $contents.each (i, el) =>
      $el = $(el)
      $el.remove() if $el.is(':not(img, br, col, td, hr, [class^="simditor-"]):empty')
      $el.remove() if uselessP($el) #and uselessP($el.prev())
      $el.find(':not(img, br, col, td, hr, [class^="simditor-"]):empty').remove()





class InputManager extends Plugin

  @className: 'InputManager'

  opts:
    pasteImage: false

  constructor: (args...) ->
    super args...
    @editor = @widget
    @opts.pasteImage = 'inline' if @opts.pasteImage and typeof @opts.pasteImage != 'string'

  _modifierKeys: [16, 17, 18, 91, 93, 224]

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
      # make sure each code block, img and table has a p following it
      @editor.body.find('hr, pre, .simditor-image, .simditor-table').each (i, el) =>
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

    # fix firefox cmd+left/right bug
    if @editor.util.browser.firefox
      @addShortcut 'cmd+37', (e) =>
        e.preventDefault()
        @editor.selection.sel.modify('move', 'backward', 'lineboundary')
      @addShortcut 'cmd+39', (e) =>
        e.preventDefault()
        @editor.selection.sel.modify('move', 'forward', 'lineboundary')

    if @editor.textarea.attr 'autofocus'
      setTimeout =>
        @editor.focus()
      , 0

  _onFocus: (e) ->
    @editor.el.addClass('focus')
      .removeClass('error')
    @focused = true
    @lastCaretPosition = null

    @editor.body.find('.selected').removeClass('selected')

    setTimeout =>
      @editor.triggerHandler 'focus'
      #@editor.trigger 'selectionchanged'
    , 0

  _onBlur: (e) ->
    @editor.el.removeClass 'focus'
    @editor.sync()
    @focused = false
    @lastCaretPosition = @editor.undoManager.currentState()?.caret

    @editor.triggerHandler 'blur'

  _onMouseUp: (e) ->
    return if $(e.target).is('img, .simditor-image')
    @editor.trigger 'selectionchanged'
    @editor.undoManager.update()

  _onKeyDown: (e) ->
    if @editor.triggerHandler(e) == false
      return false

    # handle predefined shortcuts
    shortcutKey = @editor.util.getShortcutKey e
    if @_shortcuts[shortcutKey]
      @_shortcuts[shortcutKey].call(this, e)
      return false

    # Check the condictional handlers
    if e.which of @_keystrokeHandlers
      result = @_keystrokeHandlers[e.which]['*']?(e)
      if result
        @editor.trigger 'valuechanged'
        @editor.trigger 'selectionchanged'
        return false

      @editor.util.traverseUp (node) =>
        return unless node.nodeType == 1
        handler = @_keystrokeHandlers[e.which]?[node.tagName.toLowerCase()]
        result = handler?(e, $(node))
        !result
      if result
        @editor.trigger 'valuechanged'
        @editor.trigger 'selectionchanged'
        return false

    if e.which in @_modifierKeys or e.which in @_arrowKeys
      return

    metaKey = @editor.util.metaKey e
    $blockEl = @editor.util.closestBlockEl()

    # paste shortcut
    return if metaKey and e.which == 86

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
      @editor.undoManager.update()
      return

    if e.which == 8 and (@editor.body.is(':empty') or (@editor.body.children().length == 1 and @editor.body.children().is('br')))
      @editor.body.empty()
      p = $('<p/>').append(@editor.util.phBr)
        .appendTo(@editor.body)
      @editor.selection.setRangeAtStartOf p
      return

  _onPaste: (e) ->
    if @editor.triggerHandler(e) == false
      return false

    if e.originalEvent.clipboardData && e.originalEvent.clipboardData.items && e.originalEvent.clipboardData.items.length > 0
      pasteItem = e.originalEvent.clipboardData.items[0]

      # paste file in chrome
      if /^image\//.test pasteItem.type
        imageFile = pasteItem.getAsFile()
        return unless imageFile? and @opts.pasteImage

        unless imageFile.name
          imageFile.name = "来自剪贴板的图片.png";

        uploadOpt = {}
        uploadOpt[@opts.pasteImage] = true
        @editor.uploader?.upload(imageFile, uploadOpt)
        return false


    $blockEl = @editor.util.closestBlockEl()
    cleanPaste = $blockEl.is 'pre, table'
    @editor.selection.deleteRangeContents()
    @editor.selection.save()

    @_pasteArea.focus()

    setTimeout =>
      if @_pasteArea.is(':empty')
        pasteContent = null
      else if cleanPaste
        pasteContent = @editor.formatter.clearHtml @_pasteArea.html()
        pasteContent = pasteContent.replace /\n/g, '<br/>' if $blockEl.is('table')
      else
        pasteContent = $('<div/>').append(@_pasteArea.contents())
        @editor.formatter.format pasteContent
        @editor.formatter.decorate pasteContent
        @editor.formatter.beautify pasteContent.children()
        pasteContent = pasteContent.contents()

      @_pasteArea.empty()
      range = @editor.selection.restore()

      if @editor.triggerHandler('pasting', [pasteContent]) == false
        return

      if !pasteContent
        return
      else if cleanPaste
        pasteContent = $('<div/>').append(pasteContent)
        @editor.selection.insertNode($(node)[0], range) for node in pasteContent.contents()
      else if pasteContent.length < 1
        return
      else if pasteContent.length == 1
        if pasteContent.is('p')
          children = pasteContent.contents()
          @editor.selection.insertNode node, range for node in children

        # paste image in firefox
        else if pasteContent.is('.simditor-image')
          $img = pasteContent.find('img')

          # firefox
          if dataURLtoBlob && $img.is('img[src^="data:image/png;base64"]')
            return unless @opts.pasteImage
            blob = dataURLtoBlob $img.attr( "src" )
            blob.name = "来自剪贴板的图片.png"

            uploadOpt = {}
            uploadOpt[@opts.pasteImage] = true
            @editor.uploader?.upload(blob, uploadOpt)
            return

          # cannot paste image in safari
          else if imgEl.is('img[src^="webkit-fake-url://"]')
            return
        else if $blockEl.is('p') and @editor.util.isEmptyNode $blockEl
          $blockEl.replaceWith pasteContent
          @editor.selection.setRangeAtEndOf(pasteContent, range)
        else if pasteContent.is('ul, ol') and $blockEl.is 'li'
          $blockEl.parent().after pasteContent
          @editor.selection.setRangeAtEndOf(pasteContent, range)
        else
          $blockEl.after pasteContent
          @editor.selection.setRangeAtEndOf(pasteContent, range)
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
  _keystrokeHandlers: {}

  addKeystrokeHandler: (key, node, handler) ->
    @_keystrokeHandlers[key] = {} unless @_keystrokeHandlers[key]
    @_keystrokeHandlers[key][node] = handler


  # a hook will be triggered when specific string typed
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








# Standardize keystroke actions across browsers

class Keystroke extends Plugin

  @className: 'Keystroke'

  constructor: (args...) ->
    super args...
    @editor = @widget

  _init: ->

    # safari doesn't support shift + enter default behavior
    if @editor.util.browser.safari
      @editor.inputManager.addKeystrokeHandler '13', '*', (e) =>
        return unless e.shiftKey
        $br = $('<br/>')

        if @editor.selection.rangeAtEndOf $blockEl
          @editor.selection.insertNode $br
          @editor.selection.insertNode $('<br/>')
          @editor.selection.setRangeBefore $br
        else
          @editor.selection.insertNode $br

        true


    # Remove hr and img node
    @editor.inputManager.addKeystrokeHandler '8', '*', (e) =>
      $rootBlock = @editor.util.furthestBlockEl()
      $prevBlockEl = $rootBlock.prev()
      if $prevBlockEl.is('hr, .simditor-image') and @editor.selection.rangeAtStartOf $rootBlock
        # TODO: need to test on IE
        @editor.selection.save()
        $prevBlockEl.remove()
        @editor.selection.restore()
        return true


    # Tab to indent
    @editor.inputManager.addKeystrokeHandler '9', '*', (e) =>
      return unless @editor.opts.tabIndent

      if e.shiftKey
        @editor.util.outdent()
      else
        @editor.util.indent()
      true


    # press enter in a empty list item
    @editor.inputManager.addKeystrokeHandler '13', 'li', (e, $node) =>
      $cloneNode = $node.clone()
      $cloneNode.find('ul, ol').remove()
      return unless @editor.util.isEmptyNode($cloneNode) and $node.is(@editor.util.closestBlockEl())
      listEl = $node.parent()

      # item in the middle of list
      if $node.next('li').length > 0
        return unless @editor.util.isEmptyNode($node)

        # in a nested list
        if listEl.parent('li').length > 0
          newBlockEl = $('<li/>').append(@editor.util.phBr).insertAfter(listEl.parent('li'))
          newListEl = $('<' + listEl[0].tagName + '/>').append($node.nextAll('li'))
          newBlockEl.append newListEl
        # in a root list
        else
          newBlockEl = $('<p/>').append(@editor.util.phBr).insertAfter(listEl)
          newListEl = $('<' + listEl[0].tagName + '/>').append($node.nextAll('li'))
          newBlockEl.after newListEl

      # item at the end of list
      else
        # in a nested list
        if listEl.parent('li').length > 0
          newBlockEl = $('<li/>').insertAfter(listEl.parent('li'))
          if $node.contents().length > 0
            newBlockEl.append $node.contents()
          else
            newBlockEl.append @editor.util.phBr
        # in a root list
        else
          newBlockEl = $('<p/>').append(@editor.util.phBr).insertAfter(listEl)
          newBlockEl.after $node.children('ul, ol') if $node.children('ul, ol').length > 0

      if $node.prev('li').length
        $node.remove()
      else
        listEl.remove()

      @editor.selection.setRangeAtStartOf newBlockEl
      true


    # press enter in a code block: insert \n instead of br
    @editor.inputManager.addKeystrokeHandler '13', 'pre', (e, $node) =>
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
    @editor.inputManager.addKeystrokeHandler '13', 'blockquote', (e, $node) =>
      $closestBlock = @editor.util.closestBlockEl()
      return unless $closestBlock.is('p') and !$closestBlock.next().length and @editor.util.isEmptyNode $closestBlock
      $node.after $closestBlock
      @editor.selection.setRangeAtStartOf $closestBlock
      true


    # press delete in a empty li which has a nested list
    @editor.inputManager.addKeystrokeHandler '8', 'li', (e, $node) =>
      $childList = $node.children('ul, ol')
      $prevNode = $node.prev('li')
      return unless $childList.length > 0 and $prevNode.length > 0

      text = ''
      $textNode = null
      $node.contents().each (i, n) =>
        if n.nodeType == 3 and n.nodeValue
          text += n.nodeValue
          $textNode = $(n)
      if $textNode and text.length == 1 and @editor.util.browser.firefox and !$textNode.next('br').length
        $br = $(@editor.util.phBr).insertAfter $textNode
        $textNode.remove()
        @editor.selection.setRangeBefore $br
        return true
      else if text.length > 0
        return

      range = document.createRange()
      $prevChildList = $prevNode.children('ul, ol')
      if $prevChildList.length > 0
        $newLi = $('<li/>').append(@editor.util.phBr).appendTo($prevChildList)
        $prevChildList.append $childList.children('li')
        $node.remove()
        @editor.selection.setRangeAtEndOf $newLi, range
      else
        @editor.selection.setRangeAtEndOf $prevNode, range
        $prevNode.append $childList
        $node.remove()
        @editor.selection.selectRange range
      true


    # press delete at start of code block
    @editor.inputManager.addKeystrokeHandler '8', 'pre', (e, $node) =>
      return unless @editor.selection.rangeAtStartOf $node
      codeStr = $node.html().replace('\n', '<br/>')
      $newNode = $('<p/>').append(codeStr || @editor.util.phBr).insertAfter $node
      $node.remove()
      @editor.selection.setRangeAtStartOf $newNode
      true


    # press delete at start of blockquote
    @editor.inputManager.addKeystrokeHandler '8', 'blockquote', (e, $node) =>
      return unless @editor.selection.rangeAtStartOf $node
      $firstChild = $node.children().first().unwrap()
      @editor.selection.setRangeAtStartOf $firstChild
      true



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
    if @editor.util.os.mac
      undoShortcut = 'cmd+90'
      redoShortcut = 'shift+cmd+90'
    else
      undoShortcut = 'ctrl+90'
      redoShortcut = 'ctrl+89'

    @editor.inputManager.addShortcut undoShortcut, (e) =>
      e.preventDefault()
      @undo()

    @editor.inputManager.addShortcut redoShortcut, (e) =>
      e.preventDefault()
      @redo()

    @editor.on 'valuechanged', (e, src) =>
      return if src == 'undo'

      if @_timer
        clearTimeout @_timer
        @_timer = null

      @_timer = setTimeout =>
        @_pushUndoState()
      , 200

  _pushUndoState: ->
    currentState = @currentState()
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
    @editor.body.html state.html
    @caretPosition state.caret
    @editor.find('.selected').removeClass('selected')
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
    @editor.find('.selected').removeClass('selected')
    @editor.sync()

    @editor.trigger 'valuechanged', ['undo']
    @editor.trigger 'selectionchanged', ['undo']

  update: () ->
    currentState = @currentState()
    return unless currentState

    html = @editor.body.html()
    currentState.html = html
    currentState.caret = @caretPosition()

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

    for offset, i in position[0...position.length - 1]
      childNodes = node.childNodes
      if offset > childNodes.length - 1
        # when pre is empty, the text node will be lost
        if i == position.length - 2 and $(node).is('pre')
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
    @phBr = '' if @browser.msie and @browser.version < 11
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
    !$node.text() and !$node.find(':not(br, span)').length

  isBlockNode: (node) ->
    node = $(node)[0]
    if !node or node.nodeType == 3
      return false

    /^(div|p|ul|ol|li|blockquote|hr|pre|h1|h2|h3|h4|table)$/.test node.nodeName.toLowerCase()

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

  indent: () ->
    $blockEl = @editor.util.closestBlockEl()
    return false unless $blockEl and $blockEl.length > 0

    if $blockEl.is('pre')
      spaceNode = document.createTextNode '\u00A0\u00A0'
      @editor.selection.insertNode spaceNode
    else if $blockEl.is('li')
      $parentLi = $blockEl.prev('li')
      return false if $parentLi.length < 1

      @editor.selection.save()
      tagName = $blockEl.parent()[0].tagName
      $childList = $parentLi.children('ul, ol')

      if $childList.length > 0
        $childList.append $blockEl
      else
        $('<' + tagName + '/>')
          .append($blockEl)
          .appendTo($parentLi)

      @editor.selection.restore()
    else if $blockEl.is 'p, h1, h2, h3, h4'
      indentLevel = $blockEl.attr('data-indent') ? 0
      indentLevel = indentLevel * 1 + 1
      indentLevel = 10 if indentLevel > 10
      $blockEl.attr 'data-indent', indentLevel
    else if $blockEl.is 'table'
      range = @editor.selection.getRange()
      $td = $(range.commonAncestorContainer).closest('td')
      $nextTd = $td.next('td')
      $nextTd = $td.parent('tr').next('tr').find('td:first') unless $nextTd.length > 0
      return false unless $td.length > 0 and $nextTd.length > 0
      @editor.selection.setRangeAtEndOf $nextTd
    else
      spaceNode = document.createTextNode '\u00A0\u00A0\u00A0\u00A0'
      @editor.selection.insertNode spaceNode

    @editor.trigger 'valuechanged'
    @editor.trigger 'selectionchanged'
    true

  outdent: () ->
    $blockEl = @editor.util.closestBlockEl()
    return false unless $blockEl and $blockEl.length > 0

    if $blockEl.is('pre')
      # TODO: outdent in code block
      return false
    else if $blockEl.is('li')
      $parent = $blockEl.parent()
      $parentLi = $parent.parent('li')

      if $parentLi.length < 1
        button = @editor.toolbar.findButton $parent[0].tagName.toLowerCase()
        button?.command()
        return false

      @editor.selection.save()

      if $blockEl.next('li').length > 0
        $('<' + $parent[0].tagName + '/>')
          .append($blockEl.nextAll('li'))
          .appendTo($blockEl)

      $blockEl.insertAfter $parentLi
      $parent.remove() if $parent.children('li').length < 1
      @editor.selection.restore()
    else if $blockEl.is 'p, h1, h2, h3, h4'
      indentLevel = $blockEl.attr('data-indent') ? 0
      indentLevel = indentLevel * 1 - 1
      indentLevel = 0 if indentLevel < 0
      $blockEl.attr 'data-indent', indentLevel
    else if $blockEl.is 'table'
      range = @editor.selection.getRange()
      $td = $(range.commonAncestorContainer).closest('td')
      $prevTd = $td.prev('td')
      $prevTd = $td.parent('tr').prev('tr').find('td:last') unless $prevTd.length > 0
      return false unless $td.length > 0 and $prevTd.length > 0
      @editor.selection.setRangeAtEndOf $prevTd
    else
      return false

    @editor.trigger 'valuechanged'
    @editor.trigger 'selectionchanged'
    true


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
      @opts.toolbar = ['bold', 'italic', 'underline', 'strikethrough', '|', 'ol', 'ul', 'blockquote', 'code', '|', 'link', 'image', '|', 'indent', 'outdent']

    @_render()

    @list.on 'click', (e) =>
      false

    @wrapper.on 'mousedown', (e) =>
      @list.find('.menu-on').removeClass('.menu-on')

    $(document).on 'mousedown.simditor', (e) =>
      @list.find('.menu-on').removeClass('.menu-on')

    if @opts.toolbarFloat
      @wrapper.width @wrapper.outerWidth()
      @wrapper.css 'left', @wrapper.offset().left
      $(window).on 'scroll.simditor-' + @editor.id, (e) =>
        topEdge = @editor.wrapper.offset().top
        bottomEdge = topEdge + @editor.wrapper.outerHeight() - 80
        scrollTop = $(document).scrollTop()

        if scrollTop <= topEdge or scrollTop >= bottomEdge
          @editor.wrapper.removeClass('toolbar-floating')
        else
          @editor.wrapper.addClass('toolbar-floating')

    @editor.on 'selectionchanged focus', =>
      @toolbarStatus()

    @editor.on 'destroy', =>
      @buttons.length = 0

    $(document).on 'mousedown.simditor-' + @editor.id, (e) =>
      @list.find('li.menu-on').removeClass('menu-on')

  _render: ->
    @buttons = []
    @wrapper = $(@_tpl.wrapper).prependTo(@editor.wrapper)
    @list = @wrapper.find('ul')

    for name in @opts.toolbar
      if name == '|'
        $(@_tpl.separator).appendTo @list
        continue

      unless @constructor.buttons[name]
        throw new Error 'simditor: invalid toolbar button "' + name + '"'
        continue

      @buttons.push new @constructor.buttons[name](@editor)

  toolbarStatus: (name) ->
    return unless @editor.inputManager.focused

    buttons = @buttons[..]
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

  findButton: (name) ->
    button = @list.find('.toolbar-item-' + name).data('button')
    button ? null

  @addButton: (btn) ->
    @buttons[btn::name] = btn

  @buttons: {}




class Simditor extends Widget
  @connect Util
  @connect UndoManager
  @connect InputManager
  @connect Keystroke
  @connect Formatter
  @connect Selection
  @connect Toolbar

  @count: 0

  opts:
    textarea: null
    placeholder: ''
    defaultImage: 'images/image.png'
    params: {}
    upload: false
    tabIndent: true

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

    if @opts.upload and simple?.uploader
      uploadOpts = if typeof @opts.upload == 'object' then @opts.upload else {}
      @uploader = simple.uploader(uploadOpts)

    form = @textarea.closest 'form'
    if form.length
      form.on 'submit.simditor-' + @id, =>
        @sync()
      form.on 'reset.simditor-' + @id, =>
        @setValue ''

    # set default value after all plugins are connected
    @on 'pluginconnected', =>
      @setValue @textarea.val() || ''

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
    if children.length == 0 or (children.length == 1 and @util.isEmptyNode(children) and (children.data('indent') ? 0) < 1)
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
    @formatter.undecorate cloneBody
    @formatter.format cloneBody

    # generate `a` tag automatically
    @formatter.autolink cloneBody

    # remove empty `p` tag at the end of content
    lastP = cloneBody.children().last 'p'
    while lastP.is('p') and !lastP.text() and !lastP.find('img').length
      emptyP = lastP
      lastP = lastP.prev 'p'
      emptyP.remove()

    val = $.trim(cloneBody.html())
    @textarea.val val
    val

  focus: ->
    $blockEl = @body.find('p, li, pre, h1, h2, h3, h4, td').first()
    return unless $blockEl.length > 0
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


class TestPlugin extends Plugin

class Test extends Widget
  @connect TestPlugin


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
      if @menu
        @wrapper.toggleClass('menu-on')
          .siblings('li')
          .removeClass('menu-on')
        return false

      return false if @el.hasClass('disabled') or (@needFocus and !@editor.inputManager.focused)

      param = @el.data('param')
      @command(param)
      false

    @wrapper.on 'click', 'a.menu-item', (e) =>
      e.preventDefault()
      btn = $(e.currentTarget)
      @wrapper.removeClass('menu-on')
      return false if btn.hasClass('disabled') or (@needFocus and !@editor.inputManager.focused)

      @editor.toolbar.wrapper.removeClass('menu-on')
      param = btn.data('param')
      @command(param)
      false

    @wrapper.on 'mousedown', 'a.menu-item', (e) =>
      false

    @editor.on 'blur', =>
      @setActive false
      @setDisabled false


    if @shortcut?
      @editor.inputManager.addShortcut @shortcut, (e) =>
        @el.mousedown()

    for tag in @htmlTag.split ','
      tag = $.trim tag
      if tag && $.inArray(tag, @editor.formatter._allowedTags) < 0
        @editor.formatter._allowedTags.push tag

  render: ->
    @wrapper = $(@_tpl.item).appendTo @editor.toolbar.list
    @el = @wrapper.find 'a.toolbar-item'

    @el.attr('title', @title)
      .addClass('toolbar-item-' + @name)
      .data('button', @)

    @el.find('span')
      .addClass(if @icon then 'fa fa-' + @icon else '')
      .text(@text)

    return unless @menu

    @menuWrapper = $(@_tpl.menuWrapper).appendTo(@wrapper)
    @menuWrapper.addClass 'toolbar-menu-' + @name
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
          'title': menuItem.title ? menuItem.text,
          'data-param': menuItem.param
        )
        .addClass('menu-item-' + menuItem.name)
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

    @el.on 'mouseenter', (e) =>
      @el.addClass 'hover'
    @el.on 'mouseleave', (e) =>
      @el.removeClass 'hover'

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


class TitleButton extends Button

  name: 'title'

  title: '标题文字'

  htmlTag: 'h1, h2, h3, h4'

  disableTag: 'pre, table'

  menu: [{
    name: 'normal',
    text: '普通文本',
    param: 'p'
  }, '|', {
    name: 'h1',
    text: '标题 1',
    param: 'h1'
  }, {
    name: 'h2',
    text: '标题 2',
    param: 'h2'
  }, {
    name: 'h3',
    text: '标题 3',
    param: 'h3'
  }]

  setActive: (active, param) ->
    @active = active
    if active
      @el.addClass('active active-' + param)
    else
      @el.removeClass('active active-p active-h1 active-h2 active-h3')

  status: ($node) ->
    @setDisabled $node.is(@disableTag) if $node?
    return true if @disabled

    if $node?
      param = $node[0].tagName?.toLowerCase()
      @setActive $node.is(@htmlTag), param
    @active

  command: (param) ->
    range = @editor.selection.getRange()
    startNode = range.startContainer
    endNode = range.endContainer
    $startBlock = @editor.util.closestBlockEl(startNode)
    $endBlock = @editor.util.closestBlockEl(endNode)

    @editor.selection.save()

    range.setStartBefore $startBlock[0]
    range.setEndAfter $endBlock[0]

    $contents = $(range.extractContents())

    results = []
    $contents.children().each (i, el) =>
      converted = @_convertEl el, param
      results.push(c) for c in converted

    range.insertNode node[0] for node in results.reverse()
    @editor.selection.restore()

    @editor.trigger 'valuechanged'
    @editor.trigger 'selectionchanged'

  _convertEl: (el, param) ->
    $el = $(el)
    results = []

    if $el.is param
      results.push $el
    else
      $block = $('<' + param + '/>').append($el.contents())
      results.push($block)

    results


Simditor.Toolbar.addButton(TitleButton)



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

  disableTag: 'pre, table'

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

  disableTag: 'li, table'

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
      if !$el.text() and $el.children().length == 1 and $el.children().is('br')
        codeStr = '\n'
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
    @setDisabled $node.is(@disableTag) if $node?
    return true if @disabled

    return @active unless $node?

    showPopover = true
    if !$node.is(@htmlTag) or $node.is('[class^="simditor-"]')
      @setActive false
      showPopover = false
    else if @editor.selection.rangeAtEndOf($node)
      @setActive true
      showPopover = false
    else
      @setActive true

    if showPopover
      @popover.show($node)
    else if @editor.util.isBlockNode($node)
      @popover.hide()

    @active

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
      linkText = @editor.formatter.clearHtml($contents.contents(), false)
      $link = $('<a/>', {
        href: 'http://www.example.com',
        target: '_blank',
        text: linkText || '链接文字'
      })

      if $startBlock[0] == $endBlock[0]
        range.insertNode $link[0]
      else
        $newBlock = $('<p/>').append($link)
        range.insertNode $newBlock[0]

      range.selectNodeContents $link[0]

      @popover.one 'popovershow', =>
        if linkText
          @popover.urlEl.focus()
          @popover.urlEl[0].select()
        else
          @popover.textEl.focus()
          @popover.textEl[0].select()

    @editor.selection.selectRange range
    @editor.trigger 'valuechanged'
    @editor.trigger 'selectionchanged'


class LinkPopover extends Popover

  _tpl: """
    <div class="link-settings">
      <div class="settings-field">
        <label>文本</label>
        <input class="link-text" type="text"/>
        <a class="btn-unlink" href="javascript:;" title="取消链接" tabindex="-1"><span class="fa fa-unlink"></span></a>
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
      if e.which == 13 or e.which == 27 or (!e.shiftKey and e.which == 9 and $(e.target).hasClass('link-url'))
        e.preventDefault()
        setTimeout =>
          range = document.createRange()
          @editor.selection.setRangeAfter @target, range
          @editor.body.focus() if @editor.util.browser.firefox
          @hide()
          @editor.trigger 'valuechanged'
          @editor.trigger 'selectionchanged'
        , 0

    @unlinkEl.on 'click', (e) =>
      txtNode = document.createTextNode @target.text()
      @target.replaceWith txtNode
      @hide()

      range = document.createRange()
      @editor.selection.setRangeAfter txtNode, range
      @editor.body.focus() if @editor.util.browser.firefox and !@editor.inputManager.focused
      @editor.trigger 'valuechanged'
      @editor.trigger 'selectionchanged'

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

  disableTag: 'pre, table'

  defaultImage: ''

  maxWidth: 0

  maxHeight: 0

  menu: [{
    name: 'upload-image',
    text: '本地图片'
  }, {
    name: 'external-image',
    text: '外链图片'
  }]

  constructor: (@editor) ->
    @menu = false unless @editor.uploader?
    super @editor

    @defaultImage = @editor.opts.defaultImage
    @maxWidth = @editor.opts.maxImageWidth || @editor.body.width()
    @maxHeight = @editor.opts.maxImageHeight || $(window).height()

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
        #$img = $imgWrapper.find('img')
        #$imgWrapper.width $img.width()
        #$imgWrapper.height $img.height()
        @popover.show $imgWrapper

      false

    @editor.body.on 'click', '.simditor-image', (e) =>
      false

    @editor.on 'selectionchanged.image', =>
      range = @editor.selection.getRange()
      return unless range?
      $container = $(range.commonAncestorContainer)

      if range.collapsed and $container.is('.simditor-image')
        $container.mousedown()
      else if @popover.active
        @popover.hide() if @popover.active

    @editor.body.on 'keydown', '.simditor-image', (e) =>
      return unless e.which == 8
      @popover.hide()
      $(e.currentTarget).remove()
      @editor.trigger 'valuechanged'
      return false

  render: (args...) ->
    super args...
    @popover = new ImagePopover(@)

  renderMenu: ->
    super()

    $uploadItem = @menuEl.find('.menu-item-upload-image')
    $input = null;

    createInput = =>
      $input.remove() if $input
      $input = $('<input type="file" title="上传图片" name="upload_file" accept="image/*">')
        .appendTo($uploadItem)

    createInput()

    $uploadItem.on 'click mousedown', 'input[name=upload_file]', (e) =>
      e.stopPropagation()

    $uploadItem.on 'change', 'input[name=upload_file]', (e) =>
      if @editor.inputManager.focused
        @editor.uploader.upload($input, {
          inline: true
        })
        createInput()
      else if @editor.inputManager.lastCaretPosition
        @editor.one 'focus', (e) =>
          @editor.uploader.upload($input, {
            inline: true
          })
          createInput()
        @editor.undoManager.caretPosition @editor.inputManager.lastCaretPosition
      @wrapper.removeClass('menu-on')

    @_initUploader()

  _initUploader: ->
    unless @editor.uploader?
      @el.find('.btn-upload').remove()
      return

    @editor.uploader.on 'beforeupload', (e, file) =>
      return unless file.inline

      if file.imgWrapper
        $img = file.imgWrapper.find("img")
      else
        $img = @createImage()
        $img.mousedown()
        file.imgWrapper = $img.parent '.simditor-image'

      @editor.uploader.readImageFile file.obj, (img) =>
        prepare = () =>
          @popover.srcEl.val('正在上传...')
          file.imgWrapper.append '<div class="mask"></div>'
          $progress = $('<div class="simditor-image-progress"><span></span></div>').appendTo file.imgWrapper
          $progress.addClass('loading') unless @editor.uploader.html5

        if img
          @loadImage $img, img.src, () =>
            @popover.refresh()
            prepare()
        else
          prepare()

    @editor.uploader.on 'uploadprogress', (e, file, loaded, total) =>
      return unless file.inline

      percent = loaded / total
      percent = (percent * 100).toFixed(0)
      percent = 99 if percent > 99

      file.imgWrapper.find(".simditor-image-progress span").text(percent)

      file.imgWrapper.find('.mask').css({
        top: percent + '%',
        height: (100 - percent) + '%'
      })

    @editor.uploader.on 'uploadsuccess', (e, file, result) =>
      return unless file.inline

      $img = file.imgWrapper.find("img")
      @loadImage $img, result.file_path, () =>
        file.imgWrapper.find(".mask, .simditor-image-progress").remove()
        @popover.srcEl.val result.file_path
        @editor.trigger 'valuechanged'

    @editor.uploader.on 'uploaderror', (e, file, xhr) =>
      return if xhr.statusText == 'abort'

      if xhr.responseText
        try
          result = $.parseJSON xhr.responseText
          msg = result.msg
        catch e
          msg = '上传出错了'

        if simple? and simple.message?
          simple.message(msg)
        else
          alert(msg)

      $img = file.imgWrapper.find("img")
      @loadImage $img, @defaultImage, =>
        @popover.refresh()
        @popover.srcEl.val $img.attr('src')
        file.imgWrapper.find(".mask, .simditor-image-progress").remove()
        @editor.trigger 'valuechanged'

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

    $img.insertAfter $wrapper unless $img.is('img[src^="data:image/png;base64"]')
    $wrapper.remove()

  loadImage: ($img, src, callback) ->
    $wrapper = $img.parent('.simditor-image')
    img = new Image()

    img.onload = =>
      width = img.width
      height = img.height
      if width > @maxWidth
        height = @maxWidth * height / width
        width = @maxWidth
      if height > @maxHeight
        width = @maxHeight * width / height
        height = @maxHeight

      $img.attr({
        src: src,
        width: width,
        'data-origin-src': src,
        'data-origin-name': '图片',
        'data-origin-size': img.width + ',' + img.height
      })

      $wrapper.width(width)
        .height(height)

      callback(true)

    img.onerror = =>
      callback(false)

    img.src = src

  createImage: () ->
    range = @editor.selection.getRange()
    startNode = range.startContainer
    endNode = range.endContainer
    $startBlock = @editor.util.closestBlockEl(startNode)
    $endBlock = @editor.util.closestBlockEl(endNode)

    range.deleteContents()

    if $startBlock[0] == $endBlock[0]
      if $startBlock.is 'li'
        $startBlock = @editor.util.furthestNode($startBlock, 'ul, ol')
        $endBlock = $startBlock
        range.setEndAfter($startBlock[0])
        range.collapse(false)
      else if $startBlock.is 'p'
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
    $img

  command: () ->
    $img = @createImage()

    @loadImage $img, @defaultImage, =>
      @editor.trigger 'valuechanged'
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
        <a class="btn-upload" href="javascript:;" title="上传图片" tabindex="-1">
          <span class="fa fa-upload"></span>
        </a>
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

    @_initUploader()

  _initUploader: ->
    $uploadBtn = @el.find('.btn-upload')
    unless @editor.uploader?
      $uploadBtn.remove()
      return

    createInput = =>
      @input.remove() if @input
      @input = $('<input type="file" title="上传图片" name="upload_file" accept="image/*">')
        .appendTo($uploadBtn)

    createInput()

    @el.on 'click mousedown', 'input[name=upload_file]', (e) =>
      e.stopPropagation()

    @el.on 'change', 'input[name=upload_file]', (e) =>
      @editor.uploader.upload(@input, {
        inline: true,
        imgWrapper: @target
      })
      createInput()

  show: (args...) ->
    super args...
    $img = @target.find('img')
    @srcEl.val $img.attr('src')


Simditor.Toolbar.addButton(ImageButton)




class IndentButton extends Button

  name: 'indent'

  icon: 'indent'

  title: '向右缩进（Tab）'

  status: ($node) ->
    true

  command: ->
    @editor.util.indent()


Simditor.Toolbar.addButton(IndentButton)



class OutdentButton extends Button

  name: 'outdent'

  icon: 'outdent'

  title: '向左缩进（Shift + Tab）'

  status: ($node) ->
    true

  command: ->
    @editor.util.outdent()


Simditor.Toolbar.addButton(OutdentButton)




class HrButton extends Button

  name: 'hr'

  icon: 'minus'

  title: '分隔线'

  htmlTag: 'hr'

  status: ($node) ->
    true

  command: ->
    $rootBlock = @editor.util.furthestBlockEl()
    $nextBlock = $rootBlock.next()

    if $nextBlock.length > 0
      @editor.selection.save()
    else
      $newBlock = $('<p/>').append @editor.util.phBr

    $hr = $('<hr/>').insertAfter $rootBlock

    if $newBlock
      $newBlock.insertAfter $hr
      @editor.selection.setRangeAtStartOf $newBlock
    else
      @editor.selection.restore()

    @editor.trigger 'valuechanged'
    @editor.trigger 'selectionchanged'


Simditor.Toolbar.addButton(HrButton)



class TableButton extends Button

  name: 'table'

  icon: 'table'

  title: '表格'

  htmlTag: 'table'

  disableTag: 'pre, li, blockquote'

  menu: true

  constructor: (args...) ->
    super args...

    $.merge @editor.formatter._allowedTags, ['tbody', 'tr', 'td', 'colgroup', 'col']
    $.extend(@editor.formatter._allowedAttributes, {
      td: ['rowspan', 'colspan'],
      col: ['width']
    })

    @editor.on 'decorate', (e, $el) =>
      $el.find('table').each (i, table) =>
        @decorate $(table)

    @editor.on 'undecorate', (e, $el) =>
      $el.find('table').each (i, table) =>
        @undecorate $(table)

    @editor.on 'selectionchanged.table', (e) =>
      @editor.body.find('.simditor-table td').removeClass('active')
      range = @editor.selection.getRange()
      return unless range?
      $container = $(range.commonAncestorContainer)

      if range.collapsed and $container.is('.simditor-table')
        if @editor.selection.rangeAtStartOf $container
          $container = $container.find('td:first')
        else
          $container = $container.find('td:last')
        @editor.selection.setRangeAtEndOf $container

      $container.closest('td', @editor.body)
        .addClass('active')


    @editor.on 'blur.table', (e) =>
      @editor.body.find('.simditor-table td').removeClass('active')

    # press left arrow in td
    #@editor.inputManager.addKeystrokeHandler '37', 'td', (e, $node) =>
      #@editor.util.outdent()
      #true

    # press right arrow in td
    #@editor.inputManager.addKeystrokeHandler '39', 'td', (e, $node) =>
      #@editor.util.indent()
      #true

    # press up arrow in td
    @editor.inputManager.addKeystrokeHandler '38', 'td', (e, $node) =>
      $tr = $node.parent 'tr'
      $prevTr = $tr.prev 'tr'
      return true unless $prevTr.length > 0
      index = $tr.find('td').index($node)
      @editor.selection.setRangeAtEndOf $prevTr.find('td').eq(index)
      true

    # press down arrow in td
    @editor.inputManager.addKeystrokeHandler '40', 'td', (e, $node) =>
      $tr = $node.parent 'tr'
      $nextTr = $tr.next 'tr'
      return true unless $nextTr.length > 0
      index = $tr.find('td').index($node)
      @editor.selection.setRangeAtEndOf $nextTr.find('td').eq(index)
      true

  initResize: ($table) ->
    $wrapper = $table.parent '.simditor-table'

    $colgroup = $table.find 'colgroup'
    if $colgroup.length < 1
      $colgroup = $('<colgroup/>').prependTo $table
      $table.find('tr:first td').each (i, td) =>
        $col = $('<col/>').appendTo $colgroup

      @refreshTableWidth $table


    $resizeHandle = $('<div class="simditor-resize-handle" contenteditable="false"></div>')
      .appendTo($wrapper)

    $wrapper.on 'mousemove', 'td', (e) =>
      return if $wrapper.hasClass('resizing')
      $td = $(e.currentTarget)
      x = e.pageX - $(e.currentTarget).offset().left;
      $td = $td.prev() if x < 5 and $td.prev().length > 0

      if $td.next('td').length < 1
        $resizeHandle.hide()
        return

      if $resizeHandle.data('td')?.is($td)
        $resizeHandle.show()
        return

      index = $td.parent().find('td').index($td)
      $col = $colgroup.find('col').eq(index)

      if $resizeHandle.data('col')?.is($col)
        $resizeHandle.show()
        return

      $resizeHandle
        .css( 'left', $td.position().left + $td.outerWidth() - 5)
        .data('td', $td)
        .data('col', $col)
        .show()

    $wrapper.on 'mouseleave', (e) =>
      $resizeHandle.hide()

    $wrapper.on 'mousedown', '.simditor-resize-handle', (e) =>
      $handle = $(e.currentTarget)
      $leftTd = $handle.data 'td'
      $leftCol = $handle.data 'col'
      $rightTd = $leftTd.next('td')
      $rightCol = $leftCol.next('col')
      startX = e.pageX
      startLeftWidth = $leftTd.outerWidth() * 1
      startRightWidth = $rightTd.outerWidth() * 1
      startHandleLeft = parseFloat $handle.css('left')
      tableWidth = $leftTd.closest('table').width()
      minWidth = 50

      $(document).on 'mousemove.simditor-resize-table', (e) =>
        deltaX = e.pageX - startX
        leftWidth = startLeftWidth + deltaX
        rightWidth = startRightWidth - deltaX
        if leftWidth < minWidth
          leftWidth = minWidth
          deltaX = minWidth - startLeftWidth
          rightWidth = startRightWidth - deltaX
        else if rightWidth < minWidth
          rightWidth = minWidth
          deltaX = startRightWidth - minWidth
          leftWidth = startLeftWidth + deltaX

        $leftCol.attr 'width', (leftWidth / tableWidth * 100) + '%'
        $rightCol.attr 'width', (rightWidth / tableWidth * 100) + '%'
        $handle.css 'left', startHandleLeft + deltaX

      $(document).one 'mouseup.simditor-resize-table', (e) =>
        $(document).off '.simditor-resize-table'
        $wrapper.removeClass 'resizing'

      $wrapper.addClass 'resizing'
      false

  decorate: ($table) ->
    if $table.parent('.simditor-table').length > 0
      @undecorate $table

    $table.wrap '<div class="simditor-table"></div>'
    @initResize $table
    $table.parent()

  undecorate: ($table) ->
    return unless $table.parent('.simditor-table').length > 0
    $table.parent().replaceWith($table)

  renderMenu: ->
    $('''
      <div class="menu-create-table">
      </div>
      <div class="menu-edit-table">
        <ul>
          <li><a tabindex="-1" unselectable="on" class="menu-item" href="javascript:;" data-param="deleteRow"><span>删除行</span></a></li>
          <li><a tabindex="-1" unselectable="on" class="menu-item" href="javascript:;" data-param="insertRowAbove"><span>在上面插入行</span></a></li>
          <li><a tabindex="-1" unselectable="on" class="menu-item" href="javascript:;" data-param="insertRowBelow"><span>在下面插入行</span></a></li>
          <li><span class="separator"></span></li>
          <li><a tabindex="-1" unselectable="on" class="menu-item" href="javascript:;" data-param="deleteCol"><span>删除列</span></a></li>
          <li><a tabindex="-1" unselectable="on" class="menu-item" href="javascript:;" data-param="insertColLeft"><span>在左边插入列</span></a></li>
          <li><a tabindex="-1" unselectable="on" class="menu-item" href="javascript:;" data-param="insertColRight"><span>在右边插入列</span></a></li>
          <li><span class="separator"></span></li>
          <li><a tabindex="-1" unselectable="on" class="menu-item" href="javascript:;" data-param="deleteTable"><span>删除表格</span></a></li>
        </ul>
      </div>
    ''').appendTo(@menuWrapper)

    @createMenu = @menuWrapper.find('.menu-create-table')
    @editMenu = @menuWrapper.find('.menu-edit-table')
    @createTable(6, 6).appendTo @createMenu

    @createMenu.on 'mouseenter', 'td', (e) =>
      @createMenu.find('td').removeClass('selected')

      $td = $(e.currentTarget)
      $tr = $td.parent()
      num = $tr.find('td').index($td) + 1
      $tr.prevAll('tr').addBack().find('td:lt(' + num + ')').addClass('selected')

    @createMenu.on 'mouseleave', (e) =>
      $(e.currentTarget).find('td').removeClass('selected')

    @createMenu.on 'mousedown', 'td', (e) =>
      @wrapper.removeClass('menu-on')
      return unless @editor.inputManager.focused

      $td = $(e.currentTarget)
      $tr = $td.parent()
      colNum = $tr.find('td').index($td) + 1
      rowNum = $tr.prevAll('tr').length + 1
      $table = @createTable(rowNum, colNum, true)

      $closestBlock = @editor.util.closestBlockEl()
      if @editor.util.isEmptyNode $closestBlock
        $closestBlock.replaceWith $table
      else
        $closestBlock.after $table

      @decorate $table
      @editor.selection.setRangeAtStartOf $table.find('td:first')
      @editor.trigger 'valuechanged'
      @editor.trigger 'selectionchanged'
      false

  createTable: (row, col, phBr) ->
    $table = $('<table/>')
    $tbody = $('<tbody/>').appendTo $table
    for r in [0...row]
      $tr = $('<tr/>').appendTo $tbody
      for c in [0...col]
        $td = $('<td/>').appendTo $tr
        $td.append(@editor.util.phBr) if phBr
    $table

  refreshTableWidth: ($table)->
    tableWidth = $table.width()
    cols = $table.find('col')
    $table.find('tr:first td').each (i, td) =>
      $col = cols.eq(i)
      $col.attr 'width', ($(td).outerWidth() / tableWidth * 100) + '%'

  setActive: (active) ->
    super active

    if active
      @createMenu.hide()
      @editMenu.show()
    else
      @createMenu.show()
      @editMenu.hide()

  deleteRow: ($td) ->
    $tr = $td.parent 'tr'
    if $tr.siblings('tr').length < 1
      @deleteTable $td
    else
      $newTr = $tr.next 'tr'
      $newTr = $tr.prev 'tr' unless $newTr.length > 0
      index = $tr.find('td').index($td)
      $tr.remove()
      @editor.selection.setRangeAtEndOf $newTr.find('td').eq(index)

  insertRow: ($td, direction = 'after') ->
    $tr = $td.parent 'tr'
    $table = $tr.closest 'table'

    colNum = 0
    $table.find('tr').each (i, tr) =>
      colNum = Math.max colNum, $(tr).find('td').length

    $newTr = $('<tr/>')
    for i in [1..colNum]
      $('<td/>').append(@editor.util.phBr).appendTo($newTr)

    $tr[direction] $newTr
    index = $tr.find('td').index($td)
    @editor.selection.setRangeAtStartOf $newTr.find('td').eq(index)

  deleteCol: ($td) ->
    $tr = $td.parent 'tr'
    if $tr.siblings('tr').length < 1 and $td.siblings('td').length < 1
      @deleteTable $td
    else
      index = $tr.find('td').index($td)
      $newTd = $td.next 'td'
      $newTd = $tr.prev 'td' unless $newTd.length > 0
      $table = $tr.closest 'table'

      $table.find('col').eq(index).remove()
      $table.find('tr').each (i, tr) =>
        $(tr).find('td').eq(index).remove()
      @refreshTableWidth $table

      @editor.selection.setRangeAtEndOf $newTd

  insertCol: ($td, direction = 'after') ->
    $tr = $td.parent 'tr'
    index = $tr.find('td').index($td)
    $table = $td.closest 'table'
    $col = $table.find('col').eq(index)

    $table.find('tr').each (i, tr) =>
      $newTd = $('<td/>').append(@editor.util.phBr)
      $(tr).find('td').eq(index)[direction] $newTd

    $newCol = $('<col/>')
    $col[direction] $newCol

    tableWidth = $table.width()
    width = Math.max parseFloat($col.attr('width')) / 2, 50 / tableWidth * 100
    $col.attr 'width', width + '%'
    $newCol.attr 'width', width + '%'
    @refreshTableWidth $table

    $newTd = if direction == 'after' then $td.next('td') else $td.prev('td')
    @editor.selection.setRangeAtStartOf $newTd

  deleteTable: ($td) ->
    $table = $td.closest '.simditor-table'
    $block = $table.next('p')
    $table.remove()
    @editor.selection.setRangeAtStartOf($block) if $block.length > 0

  command: (param) ->
    range = @editor.selection.getRange()
    $td = $(range.commonAncestorContainer).closest('td')
    return unless $td.length > 0

    if param == 'deleteRow'
      @deleteRow $td
    else if param == 'insertRowAbove'
      @insertRow $td, 'before'
    else if param == 'insertRowBelow'
      @insertRow $td
    else if param == 'deleteCol'
      @deleteCol $td
    else if param == 'insertColLeft'
      @insertCol $td, 'before'
    else if param == 'insertColRight'
      @insertCol $td
    else if param == 'deleteTable'
      @deleteTable $td
    else
      return

    @editor.trigger 'valuechanged'
    @editor.trigger 'selectionchanged'


Simditor.Toolbar.addButton TableButton



class StrikethroughButton extends Button

  name: 'strikethrough'

  icon: 'strikethrough'

  title: '删除线文字'

  htmlTag: 'strike'

  disableTag: 'pre'

  status: ($node) ->
    @setDisabled $node.is(@disableTag) if $node?
    return true if @disabled

    active = document.queryCommandState('strikethrough') is true
    @setActive active
    active

  command: ->
    document.execCommand 'strikethrough'
    @editor.trigger 'valuechanged'
    @editor.trigger 'selectionchanged'


Simditor.Toolbar.addButton(StrikethroughButton)
