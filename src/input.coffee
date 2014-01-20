
class InputManager

  opts:
    tabIndent: true

  _modifierKeys: [16, 17, 18, 91, 93]

  _arrowKeys: [37..40]

  constructor: (@editor) ->
    $.extend(@opts, @editor.opts)

    @_pasteArea = $('<textarea/>')
      .attr('tabIndex', '-1')
      .addClass('simditor-paste-area')
      .appendTo(@.editor.el)

    @editor.on 'destroy', =>
      @_pasteArea.remove()

    @editor.body.on('keydown', $.proxy(@_onKeyDown, this))
      .on('keyup', $.proxy(@_onKeyUp, this))
      .on('mouseUp', $.proxy(@_onMouseUp, this))
      .on('focus', $.proxy(@_onFocus, this))
      .on('blur', $.proxy(@_onBlur, this))
      .on('paste', $.proxy(@_onPaste, this))

    if @editor.textarea.attr 'autofocus'
      setTimeout =>
        @editor.body.focus()
      , 0

  _onFocus: (e) ->
    @editor.el.addClass('focus')
      .removeClass('error')
    @focused = true
    @editor.formatter.format()

  _onBlur: (e) ->
    @editor.el.removeClass 'focus'
    @focused = false

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
      return false

    # Remove hr node
    if e.which == 8
      $prevBlockEl = $blockEl.prev()
      if $prevBlockEl.is 'hr' and @editor.selection.rangeAtStartOf $blockEl
        # TODO: need to test on IE
        $prevBlockEl.remove()
        @editor.trigger 'valuechanged'
        return false

    # Tab to indent
    if e.which == 9 and (@opts.tabIndent or $blockEl.is 'pre')
      spaces = if $blockEl.is 'pre' then '\u00A0\u00A0' else '\u00A0\u00A0\u00A0\u00A0'
      spaceNode = document.createTextNode spaces
      @editor.selection.insertNode spaceNode
      @editor.trigger 'valuechanged'
      return false

    # Check the condictional handlers
    if e.which of @_inputHandlers
      @editor.util.traverseUp (node) =>
        return unless node.nodeType == 1
        handler = @_inputHandlers[e.which]?[node.tagName.toLowerCase()]
        handler?.call(this, $(node))

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
      li: ($node) ->

      pre: ($node) ->

      blockquote: ($node) ->

  _shortcuts:
    13: (e) ->
      @editor.el.closest('form')
        .find('button:submit')
        .click()

  addShortcut: (keyCode, handler) ->
    @_shortcuts[keyCode] = $.proxy(handler, this)





