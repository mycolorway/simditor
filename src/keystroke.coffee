
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

