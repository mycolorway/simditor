
class Indentation extends SimpleModule

  @pluginName: 'Indentation'

  opts:
    tabIndent: true

  _init: ->
    @editor = @_module

    # Tab to indent
    @editor.inputManager.addKeystrokeHandler '9', '*', (e) =>
      codeButton = @editor.toolbar.findButton 'code'
      return unless @opts.tabIndent or (codeButton and codeButton.active)

      @indent e.shiftKey

  indent: (isBackward) ->
    range = @editor.selection.getRange()
    return unless range

    $startBlock = @editor.util.closestBlockEl range.startContainer
    $endBlock = @editor.util.closestBlockEl range.endContainer

    unless $startBlock.is('li') and $endBlock.is('li') and $startBlock.parent().is($endBlock.parent())
      $startBlock = @editor.util.furthestBlockEl $startBlock
      $endBlock = @editor.util.furthestBlockEl $endBlock

    if $startBlock.is($endBlock)
      $blockEls = $startBlock
    else
      $blockEls = $startBlock.nextUntil($endBlock).add($startBlock).add($endBlock)

    result = false
    $blockEls.each (i, blockEl) =>
      result = if isBackward
        @outdentBlock(blockEl)
      else
        @indentBlock(blockEl)

    result

  indentBlock: (blockEl) ->
    $blockEl = $(blockEl)
    return unless $blockEl.length

    if $blockEl.is('pre')
      range = @editor.selection.getRange()
      $pre = $(range.commonAncestorContainer)
      return unless $pre.is($blockEl) or $pre.closest('pre').is($blockEl)
      @indentText range
      # spaceNode = document.createTextNode '\u00A0\u00A0'
      # @editor.selection.insertNode spaceNode
    else if $blockEl.is('li')
      $parentLi = $blockEl.prev('li')
      return if $parentLi.length < 1

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
      indentLevel = $blockEl.attr('data-indent') || 0
      indentLevel = Math.min(indentLevel * 1 + 1, 10)
      $blockEl.attr 'data-indent', indentLevel
    else if $blockEl.is('table') or $blockEl.is('.simditor-table')
      range = @editor.selection.getRange()
      $td = $(range.commonAncestorContainer).closest('td')
      $nextTd = $td.next('td')
      $nextTd = $td.parent('tr').next('tr').find('td:first') unless $nextTd.length > 0
      return false unless $td.length > 0 and $nextTd.length > 0
      @editor.selection.setRangeAtEndOf $nextTd

    true

  indentText: (range) ->
    text = range.toString().replace /^(?=.+)/mg, '\u00A0\u00A0'
    textNode = document.createTextNode(text || '\u00A0\u00A0')
    range.deleteContents()
    range.insertNode textNode

    if text
      range.selectNode textNode
      @editor.selection.selectRange range
    else
      @editor.selection.setRangeAfter textNode

  outdentBlock: (blockEl) ->
    $blockEl = $(blockEl)
    return unless $blockEl and $blockEl.length > 0

    if $blockEl.is('pre')
      range = @editor.selection.getRange()
      $pre = $(range.commonAncestorContainer)
      return unless $pre.is($blockEl) or $pre.closest('pre').is($blockEl)
      @outdentText range
    else if $blockEl.is('li')
      $parent = $blockEl.parent()
      $parentLi = $parent.parent('li')

      if $parentLi.length < 1
        button = @editor.toolbar.findButton $parent[0].tagName.toLowerCase()
        button?.command()
        return

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
    else if $blockEl.is('table') or $blockEl.is('.simditor-table')
      range = @editor.selection.getRange()
      $td = $(range.commonAncestorContainer).closest('td')
      $prevTd = $td.prev('td')
      $prevTd = $td.parent('tr').prev('tr').find('td:last') unless $prevTd.length > 0
      return unless $td.length > 0 and $prevTd.length > 0
      @editor.selection.setRangeAtEndOf $prevTd

    true

  outdentText: (range) ->
    # TODO
    # if range.startContainer.nodeType == 3 and range.startOffset >= 2
    #   tempRange = document.createRange()
    #   tempRange.setStart range.startContainer, range.startOffset - 2
    #   tempRange.setEnd range.startContainer, range.startOffset
    #   if tempRange.toString() == '\u00A0\u00A0'
    #     range.setStart range.startContainer, range.startOffset - 2
    # else if ($prev = $(range.startContainer).prev()).length and /\u00A0\u00A0$/.test($prev.text())
    #   range.setStart $prev[0], $prev
    #
    # text = range.toString().replace /^\u00A0\u00A0/mg, ''
    # textNode = document.createTextNode text
    # range.deleteContents()
    # range.insertNode textNode
    # range.selectNode textNode
    # @editor.selection.selectRange range
