
# Standardize keystroke actions across browsers

class Keystroke extends SimpleModule

  @pluginName: 'Keystroke'

  _init: ->
    @editor = @_module

    # handlers which will be called
    # when specific key is pressed in specific node
    @_keystrokeHandlers = {}

    @_initKeystrokeHandlers()

  add: (key, node, handler) ->
    key = key.toLowerCase()
    key = @editor.hotkeys.constructor.aliases[key] || key
    @_keystrokeHandlers[key] = {} unless @_keystrokeHandlers[key]
    @_keystrokeHandlers[key][node] = handler

  respondTo: (e) ->
    key = @editor.hotkeys.constructor.keyNameMap[e.which]?.toLowerCase()
    return unless key

    # Check the condictional handlers
    if key of @_keystrokeHandlers
      result = @_keystrokeHandlers[key]['*']?(e)

      unless result
        @editor.selection.startNodes().each (i, node) =>
          return unless node.nodeType == Node.ELEMENT_NODE
          handler = @_keystrokeHandlers[key]?[node.tagName.toLowerCase()]
          result = handler?(e, $(node))

          # different result means:
          # 1. true, handler done, stop browser default action and traverse up
          # 2. false, stop traverse up
          # 3. undefined, continue traverse up
          false if result == true or result == false

      return true if result

  _initKeystrokeHandlers: ->
    # safari doesn't support shift + enter default behavior
    if @editor.util.browser.safari
      @add 'enter', '*', (e) =>
        return unless e.shiftKey
        $blockEl = @editor.selection.blockNodes().last()
        return if $blockEl.is('pre')

        $br = $('<br/>')
        if @editor.selection.rangeAtEndOf $blockEl
          @editor.selection.insertNode $br
          @editor.selection.insertNode $('<br/>')
          @editor.selection.setRangeBefore $br
        else
          @editor.selection.insertNode $br

        true


    # press enter at end of title block in webkit and IE
    if @editor.util.browser.webkit or @editor.util.browser.msie
      titleEnterHandler = (e, $node) =>
        return unless @editor.selection.rangeAtEndOf $node
        $p = $('<p/>').append(@editor.util.phBr)
          .insertAfter($node)
        @editor.selection.setRangeAtStartOf $p
        true

      @add 'enter', 'h1', titleEnterHandler
      @add 'enter', 'h2', titleEnterHandler
      @add 'enter', 'h3', titleEnterHandler
      @add 'enter', 'h4', titleEnterHandler
      @add 'enter', 'h5', titleEnterHandler
      @add 'enter', 'h6', titleEnterHandler


    @add 'backspace', '*', (e) =>
      # Remove hr
      $rootBlock = @editor.selection.rootNodes().first()
      $prevBlockEl = $rootBlock.prev()

      if $prevBlockEl.is('hr') and @editor.selection.rangeAtStartOf $rootBlock
        @editor.selection.save()
        $prevBlockEl.remove()
        @editor.selection.restore()
        return true

      # fix the span bug in webkit browsers
      $blockEl = @editor.selection.blockNodes().last()
      isWebkit = @editor.util.browser.webkit
      if isWebkit and @editor.selection.rangeAtStartOf $blockEl
        @editor.selection.save()
        @editor.formatter.cleanNode $blockEl, true
        @editor.selection.restore()
        null

    # press enter in a empty list item
    @add 'enter', 'li', (e, $node) =>
      $cloneNode = $node.clone()
      $cloneNode.find('ul, ol').remove()
      return unless @editor.util.isEmptyNode($cloneNode) and
        $node.is(@editor.selection.blockNodes().last())
      listEl = $node.parent()

      # item in the middle of list
      if $node.next('li').length > 0
        return unless @editor.util.isEmptyNode($node)

        # in a nested list
        if listEl.parent('li').length > 0
          newBlockEl = $('<li/>')
            .append(@editor.util.phBr)
            .insertAfter(listEl.parent('li'))
          newListEl = $('<' + listEl[0].tagName + '/>')
            .append($node.nextAll('li'))
          newBlockEl.append newListEl
        # in a root list
        else
          newBlockEl = $('<p/>').append(@editor.util.phBr).insertAfter(listEl)
          newListEl = $('<' + listEl[0].tagName + '/>')
            .append($node.nextAll('li'))
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
          if $node.children('ul, ol').length > 0
            newBlockEl.after $node.children('ul, ol')

      if $node.prev('li').length
        $node.remove()
      else
        listEl.remove()

      @editor.selection.setRangeAtStartOf newBlockEl
      true


    # press enter in a code block: insert \n instead of br
    # press shift + enter in code block: insert a paragrash after code block
    @add 'enter', 'pre', (e, $node) =>
      e.preventDefault()
      if e.shiftKey
        $p = $('<p/>').append(@editor.util.phBr).insertAfter($node)
        @editor.selection.setRangeAtStartOf $p
        return true

      range = @editor.selection.range()
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
      @editor.selection.range range
      true


    # press enter in the last paragraph of blockquote,
    # just leave the block quote
    @add 'enter', 'blockquote', (e, $node) =>
      $closestBlock = @editor.selection.blockNodes().last()
      return unless $closestBlock.is('p') and !$closestBlock.next().length and
        @editor.util.isEmptyNode($closestBlock)
      $node.after $closestBlock
      range = document.createRange()
      @editor.selection.setRangeAtStartOf $closestBlock, range
      true


    # press delete in a empty li which has a nested list
    @add 'backspace', 'li', (e, $node) =>
      $childList = $node.children('ul, ol')
      $prevNode = $node.prev('li')
      return false unless $childList.length > 0 and $prevNode.length > 0

      text = ''
      $textNode = null
      $node.contents().each (i, n) ->
        return false if n.nodeType is 1 and /UL|OL/.test(n.nodeName)
        return if n.nodeType is 1 and /BR/.test(n.nodeName)

        if n.nodeType is 3 and n.nodeValue
          text += n.nodeValue
        else if n.nodeType is 1
          text += $(n).text()

        $textNode= $(n)

      isFF = @editor.util.browser.firefox and !$textNode.next('br').length
      if $textNode and text.length == 1 and isFF
        $br = $(@editor.util.phBr).insertAfter $textNode
        $textNode.remove()
        @editor.selection.setRangeBefore $br
        return true
      else if text.length > 0
        return false

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
        @editor.selection.range range
      true


    # press delete at start of code block
    @add 'backspace', 'pre', (e, $node) =>
      return unless @editor.selection.rangeAtStartOf $node
      codeStr = $node.html().replace('\n', '<br/>') || @editor.util.phBr
      $newNode = $('<p/>').append(codeStr).insertAfter $node
      $node.remove()
      range = document.createRange()
      @editor.selection.setRangeAtStartOf $newNode, range
      true


    # press delete at start of blockquote
    @add 'backspace', 'blockquote', (e, $node) =>
      return unless @editor.selection.rangeAtStartOf $node
      $firstChild = $node.children().first().unwrap()
      range = document.createRange()
      @editor.selection.setRangeAtStartOf $firstChild, range
      true
