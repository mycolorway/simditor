
class Indentation extends SimpleModule

  @pluginName: 'Indentation'

  opts:
    tabIndent: true

  _init: ->
    @editor = @_module

    # Tab to indent
    @editor.keystroke.add 'tab', '*', (e) =>
      codeButton = @editor.toolbar.findButton 'code'
      return unless @opts.tabIndent or (codeButton and codeButton.active)

      @indent e.shiftKey

  indent: (isBackward) ->
    $startNodes = @editor.selection.startNodes()
    $endNodes = @editor.selection.endNodes()
    $blockNodes = @editor.selection.blockNodes()

    nodes = []
    $blockNodes = $blockNodes.each (i, node) ->
      include = true
      for n, j in nodes
        if $.contains(node, n)
          include = false
          break
        else if $.contains(n, node)
          nodes.splice j, 1, node
          include = false
          break
      nodes.push(node) if include
    $blockNodes = $ nodes

    result = false
    $blockNodes.each (i, blockEl) =>
      r = if isBackward
        @outdentBlock(blockEl)
      else
        @indentBlock(blockEl)
      result = r if r

    result

  indentBlock: (blockEl) ->
    $blockEl = $(blockEl)
    return unless $blockEl.length

    if $blockEl.is('pre')
      $pre = @editor.selection.containerNode()
      return unless $pre.is($blockEl) or $pre.closest('pre').is($blockEl)
      @indentText @editor.selection.range()
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
      marginLeft = parseInt($blockEl.css('margin-left')) || 0
      marginLeft = (Math.round(marginLeft / @opts.indentWidth) + 1) *
        @opts.indentWidth
      $blockEl.css 'margin-left', marginLeft
    else if $blockEl.is('table') or $blockEl.is('.simditor-table')
      $td = @editor.selection.containerNode().closest('td, th')
      $nextTd = $td.next('td, th')
      unless $nextTd.length > 0
        $tr = $td.parent('tr')
        $nextTr = $tr.next('tr')
        if $nextTr.length < 1 and $tr.parent().is('thead')
          $nextTr = $tr.parent('thead').next('tbody').find('tr:first')
        $nextTd = $nextTr.find('td:first, th:first')
      return unless $td.length > 0 and $nextTd.length > 0
      @editor.selection.setRangeAtEndOf $nextTd
    else
      return false

    true

  indentText: (range) ->
    text = range.toString().replace /^(?=.+)/mg, '\u00A0\u00A0'
    textNode = document.createTextNode(text || '\u00A0\u00A0')
    range.deleteContents()
    range.insertNode textNode

    if text
      range.selectNode textNode
      @editor.selection.range range
    else
      @editor.selection.setRangeAfter textNode

  outdentBlock: (blockEl) ->
    $blockEl = $(blockEl)
    return unless $blockEl and $blockEl.length > 0

    if $blockEl.is('pre')
      $pre = @editor.selection.containerNode()
      return unless $pre.is($blockEl) or $pre.closest('pre').is($blockEl)
      @outdentText range
    else if $blockEl.is('li')
      $parent = $blockEl.parent()
      $parentLi = $parent.parent('li')
      @editor.selection.save()

      if $parentLi.length < 1
        range = document.createRange()
        range.setStartBefore $parent[0]
        range.setEndBefore $blockEl[0]
        $parent.before range.extractContents()

        $('<p/>').insertBefore($parent)
          .after($blockEl.children('ul, ol'))
          .append($blockEl.contents())

        $blockEl.remove()
      else
        if $blockEl.next('li').length > 0
          $('<' + $parent[0].tagName + '/>')
            .append($blockEl.nextAll('li'))
            .appendTo($blockEl)

        $blockEl.insertAfter $parentLi
        $parent.remove() if $parent.children('li').length < 1

      @editor.selection.restore()
    else if $blockEl.is 'p, h1, h2, h3, h4'
      marginLeft = parseInt($blockEl.css('margin-left')) || 0
      marginLeft = Math.max(Math.round(marginLeft / @opts.indentWidth) - 1, 0) *
        @opts.indentWidth
      $blockEl.css 'margin-left', if marginLeft == 0 then '' else marginLeft
    else if $blockEl.is('table') or $blockEl.is('.simditor-table')
      $td = @editor.selection.containerNode().closest('td, th')
      $prevTd = $td.prev('td, th')
      unless $prevTd.length > 0
        $tr = $td.parent('tr')
        $prevTr = $tr.prev('tr')
        if $prevTr.length < 1 and $tr.parent().is('tbody')
          $prevTr = $tr.parent('tbody').prev('thead').find('tr:first')
        $prevTd = $prevTr.find('td:last, th:last')
      return unless $td.length > 0 and $prevTd.length > 0
      @editor.selection.setRangeAtEndOf $prevTd
    else
      return false

    true

  outdentText: (range) ->
    # TODO
