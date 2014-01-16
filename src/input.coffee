
Input =

  opts:
    tabIndent: true

  _modifierKeys: [16, 17, 18, 91, 93]

  _arrowKeys: [37..40]

  _load: ->

  _init: ->

    @_pasteArea = $('<textarea/>')
      .attr('tabIndex', '-1')
      .addClass('simditor-paste-area')
      .appendTo(@el)

    @on 'destroy', =>
      @_pasteArea.remove()

    @body.on('keydown', $.proxy(@_onKeyDown, this))
      .on('keyup', $.proxy(@_onKeyUp, this))
      .on('mouseUp', $.proxy(@_onMouseUp, this))
      .on('focus', $.proxy(@_onFocus, this))
      .on('blur', $.proxy(@_onBlur, this))
      .on('paste', $.proxy(@_onPaste, this))

    if @textarea.attr 'autofocus'
      setTimeout =>
        @body.focus()
      , 0

  _onFocus: (e) ->
    @el.addClass('focus')
      .removeClass('error')

    @focused = true

    @format()

  _onBlur: (e) ->
    @el.removeClass 'focus'
    @focused = false

  _onMouseUp: (e) ->
    @trigger 'selectionchanged'

  _onKeyDown: (e) ->
    if @triggerHandler(e) == false
      return false

    if e.which in @_modifierKeys or e.which in @_arrowKeys
      return

    metaKey = @metaKey e
    $blockEl = @closestBlockEl()

    # handle predefined shortcuts
    if metaKey and @_shortcuts[e.which]
      @_shortcuts[e.which].call(this, e)
      return false

    # safari doesn't support shift + enter default behavior
    if @browser.safari and e.which == 13 and e.shiftKey
      $br = $('<br/>')

      if @rangeAtEndOf $blockEl
        @insertNode $br
        @insertNode $('<br/>')
        @setCaretBefore $br
      else
        @insertNode $br

      @trigger 'valuechanged'
      return false

    # Remove hr node
    if e.which == 8
      $prevBlockEl = $blockEl.prev()
      if $prevBlockEl.is 'hr' and @rangeAtStartOf $blockEl
        # TODO: need to test on IE
        $prevBlockEl.remove()
        @trigger 'valuechanged'
        return false

    # Tab to indent
    if e.which == 9 and (@opts.tabIndent or $blockEl.is 'pre')
      spaces = if $blockEl.is 'pre' then '\u00A0\u00A0' else '\u00A0\u00A0\u00A0\u00A0'
      spaceNode = document.createTextNode spaces
      @insertNode spaceNode
      @trigger 'valuechanged'
      return false

    # Check the condictional handlers
    if e.which of @_inputHandlers
      @traverseUp (node) =>
        return unless node.nodeType == 1
        handler = @_inputHandlers[e.which]?[node.tagName.toLowerCase()]
        handler?.call(this, $(node))

    clearTimeout @_typing if @_typing

    @_typing = setTimeout =>
      @trigger 'valuechanged'
      @trigger 'selectionchanged'
      @_typing = false

  _onKeyUp: (e) ->
    if @triggerHandler(e) == false
      return false

    if e.which in @_arrowKeys
      @trigger 'selectionchanged'
      return

    if e.which == 8 and @body.is ':empty'
      p = $('<p/>').append(@_placeholderBr)
        .appendTo(@body)
      @setCaretAtStartOf p
      return

  _onPaste: (e) ->
    if @triggerHandler(e) == false
      return false

    $blockEl = @closestBlockEl()
    codePaste = $blockEl.is 'pre'
    @deleteRangeContents()
    @saveSelection()

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

      range = @restoreSelection()

      if codePaste and pasteContent
        node = document.createTextNode(pasteContent)
        @insertNode node, range
      else if pasteContent.length < 1
        return
      else if pasteContent.length == 1
        node = document.createTextNode(pasteContent.text())
        @insertNode node, range
      else if pasteContent.length > 1
        $blockEl = $blockEl.parent() if $blockEl.is 'li'

        if @rangeAtStartOf($blockEl, range)
          insertPosition = 'before'
        else if @rangeAtEndOf($blockEl, range)
          insertPosition = 'after'
        else
          @breakBlockEl($blockEl, range)
          insertPosition = 'before'

        $blockEl[insertPosition](pasteContent)
        @setCaretAtEndOf(pasteContent.last(), range)

      @_pasteArea.val ''
    , 0

  _inputHandlers:
    13:
      li: ($node) ->

      pre: ($node) ->

      blockquote: ($node) ->

  _shortcuts:
    13: (e) ->
      @el.closest('form')
        .find('button:submit')
        .click()

  addShortcut: (keyCode, handler) ->
    @_shortcuts[keyCode] = $.proxy(handler, this)





