
Input =

  opts:
    tabIndent: true

  _modifierKeys: [16, 17, 18, 91, 93]

  _arrowKeys: [37..40]

  _load: ->

  _init: ->
    @body.on('keydown', $.proxy(@_onKeyDown, this))
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

    # meta + enter: submit current form
    if e.which == 13 and metaKey
      e.preventDefault()
      @el.closest('form')
        .find('button:submit')
        .click()
      return

    # safari doesn't support shift + enter default behavior
    if @browser.safari and e.which == 13 and e.shiftKey
      $br = $('<br/>')

      if @rangeAtEndOf $blockEl
        @insertNode $br
        @insertNode $('<br/>')
        @setRangeBefore $br
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
      $('<p/>').append @_placeholderBr
        .appendTo @body
      return

  _onPaste: (e) ->

  _inputHandlers:
    13:
      li: ($node) ->

      pre: ($node) ->

      blockquote: ($node) ->




