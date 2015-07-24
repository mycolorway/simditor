
# Standardize keystroke actions across browsers

class Keystroke extends SimpleModule

  @pluginName: 'Keystroke'

  _init: ->
    @editor = @_module

    # safari doesn't support shift + enter default behavior
    if @editor.util.browser.safari
      @editor.inputManager.addKeystrokeHandler '13', '*', (e) =>
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

      @editor.inputManager.addKeystrokeHandler '13', 'h1', titleEnterHandler
      @editor.inputManager.addKeystrokeHandler '13', 'h2', titleEnterHandler
      @editor.inputManager.addKeystrokeHandler '13', 'h3', titleEnterHandler
      @editor.inputManager.addKeystrokeHandler '13', 'h4', titleEnterHandler
      @editor.inputManager.addKeystrokeHandler '13', 'h5', titleEnterHandler
      @editor.inputManager.addKeystrokeHandler '13', 'h6', titleEnterHandler


    @editor.inputManager.addKeystrokeHandler '8', '*', (e) =>
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
    @editor.inputManager.addKeystrokeHandler '13', 'li', (e, $node) =>
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
    @editor.inputManager.addKeystrokeHandler '13', 'pre', (e, $node) =>
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
    @editor.inputManager.addKeystrokeHandler '13', 'blockquote', (e, $node) =>
      $closestBlock = @editor.selection.blockNodes().last()
      return unless $closestBlock.is('p') and !$closestBlock.next().length and
        @editor.util.isEmptyNode($closestBlock)
      $node.after $closestBlock
      range = document.createRange()
      @editor.selection.setRangeAtStartOf $closestBlock, range
      true


    # press delete in a empty li which has a nested list
    @editor.inputManager.addKeystrokeHandler '8', 'li', (e, $node) =>
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
    @editor.inputManager.addKeystrokeHandler '8', 'pre', (e, $node) =>
      return unless @editor.selection.rangeAtStartOf $node
      codeStr = $node.html().replace('\n', '<br/>') || @editor.util.phBr
      $newNode = $('<p/>').append(codeStr).insertAfter $node
      $node.remove()
      range = document.createRange()
      @editor.selection.setRangeAtStartOf $newNode, range
      true


    # press delete at start of blockquote
    @editor.inputManager.addKeystrokeHandler '8', 'blockquote', (e, $node) =>
      return unless @editor.selection.rangeAtStartOf $node
      $firstChild = $node.children().first().unwrap()
      range = document.createRange()
      @editor.selection.setRangeAtStartOf $firstChild, range
      true
