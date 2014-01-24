
class InputManager extends Plugin

  opts:
    tabIndent: true

  _modifierKeys: [16, 17, 18, 91, 93]

  _arrowKeys: [37..40]

  _init: ->
    @_pasteArea = $('<textarea/>')
      .css({
        width: '1px',
        height: '1px',
        overflow: 'hidden',
        resize: 'none',
        position: 'fixed',
        right: '0',
        bottom: '100px'
      })
      .attr('tabIndex', '-1')
      .addClass('simditor-paste-area')
      .appendTo(@.editor.el)

    @editor.on 'destroy', =>
      @_pasteArea.remove()

    @editor.on 'valuechanged', =>
      @editor.body.find('pre').each (i, pre) =>
        $pre = $(pre)
        if $pre.next().length == 0
          $('<p/>').append(@editor.util.phBr)
            .insertAfter($pre)

    @editor.body.on('keydown', $.proxy(@_onKeyDown, @))
      .on('keyup', $.proxy(@_onKeyUp, @))
      .on('mouseup', $.proxy(@_onMouseUp, @))
      .on('focus', $.proxy(@_onFocus, @))
      .on('blur', $.proxy(@_onBlur, @))
      .on('paste', $.proxy(@_onPaste, @))

    if @editor.textarea.attr 'autofocus'
      setTimeout =>
        @editor.body.focus()
      , 0

  _onFocus: (e) ->
    @editor.el.addClass('focus')
      .removeClass('error')
    @focused = true
    #@editor.formatter.format()
    setTimeout =>
      @editor.trigger 'focus'
      @editor.trigger 'selectionchanged'
    , 0

  _onBlur: (e) ->
    @editor.el.removeClass 'focus'
    @focused = false

    @editor.trigger 'blur'

  _onMouseUp: (e) ->
    @editor.trigger 'selectionchanged'

  _onKeyDown: (e) ->
    if @editor.triggerHandler(e) == false
      return false

    if e.which in @_modifierKeys or e.which in @_arrowKeys
      return

    metaKey = @editor.util.metaKey e
    $blockEl = @editor.util.closestBlockEl()

    # handle predefined shortcuts
    if metaKey and @_shortcuts[e.which]
      @_shortcuts[e.which].call(this, e)
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
    if e.which == 9 and (@opts.tabIndent or $blockEl.is 'pre')
      spaces = if $blockEl.is 'pre' then '\u00A0\u00A0' else '\u00A0\u00A0\u00A0\u00A0'
      spaceNode = document.createTextNode spaces
      @editor.selection.insertNode spaceNode
      @editor.trigger 'valuechanged'
      @editor.trigger 'selectionchanged'
      return false

    # Check the condictional handlers
    if e.which of @_inputHandlers
      result = null
      @editor.util.traverseUp (node) =>
        return unless node.nodeType == 1
        handler = @_inputHandlers[e.which]?[node.tagName.toLowerCase()]
        result = handler?.call(@, e, $(node))
      return result

    clearTimeout @_typing if @_typing

    @_typing = setTimeout =>
      @editor.trigger 'valuechanged'
      @editor.trigger 'selectionchanged'
      @_typing = false

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

    @_pasteArea.val('').focus()

    setTimeout =>
      pasteContent = @_pasteArea.val()

      # clean paste content
      unless codePaste
        els = []
        re = /(.*)(\n*)/g
        while result = re.exec(pasteContent)
          break if !result[0]
          el = $('<p/>') unless el?
          el.append(result[1])
          if result[2].length > 1
            els.push(el[0])
            el = null
          else if result[2].length == 1
            el.append('<br/>')

        els.push el[0] if el?

        pasteContent = $(els)

      range = @editor.selection.restore()

      if codePaste and pasteContent
        node = document.createTextNode(pasteContent)
        @editor.selection.insertNode node, range
      else if pasteContent.length < 1
        return
      else if pasteContent.length == 1
        node = document.createTextNode(pasteContent.text())
        @editor.selection.insertNode node, range
      else if pasteContent.length > 1
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

      @_pasteArea.val ''
    , 0

  _inputHandlers:
    13:
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

        range.collapse()
        @editor.selection.selectRange(range)
        @editor.trigger 'valuechanged'
        @editor.trigger 'selectionchanged'
        return false

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

        range.collapse()
        @editor.selection.selectRange range
        @editor.trigger 'valuechanged'
        @editor.trigger 'selectionchanged'
        return false;

      blockquote: ($node) ->
        # TODO: press enter in the last paragraph of blockquote, just leave the block quote

  _shortcuts:
    13: (e) ->
      @editor.el.closest('form')
        .find('button:submit')
        .click()

  addShortcut: (keyCode, handler) ->
    @_shortcuts[keyCode] = $.proxy(handler, this)





