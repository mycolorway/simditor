
class InputManager extends SimpleModule

  @pluginName: 'InputManager'

  _modifierKeys: [16, 17, 18, 91, 93, 224]

  _arrowKeys: [37..40]

  _init: ->
    @editor = @_module

    @throttledValueChanged = @editor.util.throttle (params) =>
      setTimeout =>
        @editor.trigger 'valuechanged', params
      , 10
    , 300

    @throttledSelectionChanged = @editor.util.throttle =>
      @editor.trigger 'selectionchanged'
    , 50

    $(document).on 'selectionchange.simditor' + @editor.id, (e) =>
      return unless @focused and !@editor.clipboard.pasting

      # make selection range is available before triggering selectionchanged
      triggerEvent = =>
        if @_selectionTimer
          clearTimeout @_selectionTimer
          @_selectionTimer = null

        if @editor.selection._selection.rangeCount > 0
          @throttledSelectionChanged()
        else
          @_selectionTimer = setTimeout =>
            @_selectionTimer = null
            triggerEvent() if @focused
          , 10
      triggerEvent()

    @editor.on 'valuechanged', =>
      @lastCaretPosition = null

      $rootBlocks = @editor.body.children().filter (i, node) =>
        @editor.util.isBlockNode node
      if @focused and $rootBlocks.length == 0
        @editor.selection.save()
        @editor.formatter.format()
        @editor.selection.restore()

      # make sure each code block and table has siblings
      @editor.body.find('hr, pre, .simditor-table').each (i, el) =>
        $el = $(el)
        if ($el.parent().is('blockquote') or $el.parent()[0] == @editor.body[0])
          formatted = false

          if $el.next().length == 0
            $('<p/>').append(@editor.util.phBr)
              .insertAfter($el)
            formatted = true

          if $el.prev().length == 0
            $('<p/>').append(@editor.util.phBr)
              .insertBefore($el)
            formatted = true

          @throttledValueChanged() if formatted

      @editor.body.find('pre:empty').append(@editor.util.phBr)

      if !@editor.util.support.onselectionchange and @focused
        @throttledSelectionChanged()

    @editor.body.on('keydown', $.proxy(@_onKeyDown, @))
      .on('keypress', $.proxy(@_onKeyPress, @))
      .on('keyup', $.proxy(@_onKeyUp, @))
      .on('mouseup', $.proxy(@_onMouseUp, @))
      .on('focus', $.proxy(@_onFocus, @))
      .on('blur', $.proxy(@_onBlur, @))
      .on('drop', $.proxy(@_onDrop, @))
      .on 'input', $.proxy @_onInput, @

    if @editor.util.browser.firefox
      # fix firefox cmd+left/right bug
      @editor.hotkeys.add 'cmd+left', (e) =>
        e.preventDefault()
        @editor.selection._selection.modify('move', 'backward', 'lineboundary')
        false

      @editor.hotkeys.add 'cmd+right', (e) =>
        e.preventDefault()
        @editor.selection._selection.modify('move', 'forward', 'lineboundary')
        false

      # override default behavior of cmd/ctrl + a in firefox(which is buggy)
      selectAllKey = if @editor.util.os.mac then 'cmd+a' else 'ctrl+a'
      @editor.hotkeys.add selectAllKey, (e) =>
        $children = @editor.body.children()
        return unless $children.length > 0
        firstBlock = $children.first().get(0)
        lastBlock = $children.last().get(0)
        range = document.createRange()
        range.setStart firstBlock, 0
        range.setEnd lastBlock, @editor.util.getNodeLength(lastBlock)
        @editor.selection.range range
        false

    # meta + enter: submit form
    submitKey = if @editor.util.os.mac then 'cmd+enter' else 'ctrl+enter'
    @editor.hotkeys.add submitKey, (e) =>
      @editor.sync()
      @editor.el.closest('form')
        .find('button:submit')
        .click()
      false

  _onFocus: (e) ->
    return if @editor.clipboard.pasting

    @editor.el.addClass('focus')
      .removeClass('error')
    @focused = true

    setTimeout =>
      # FIX: Tab to focus in Firefox will lose correct caret position
      range = @editor.selection._selection.getRangeAt(0)
      if range.startContainer == @editor.body[0]
        if @lastCaretPosition
          @editor.undoManager.caretPosition @lastCaretPosition
        else
          $blockEl = @editor.body.children().first()
          range = document.createRange()
          @editor.selection.setRangeAtStartOf $blockEl, range

      @lastCaretPosition = null
      @editor.triggerHandler 'focus'
      @throttledSelectionChanged() unless @editor.util.support.onselectionchange
    , 0

  _onBlur: (e) ->
    return if @editor.clipboard.pasting

    @editor.el.removeClass 'focus'
    @editor.sync()
    @focused = false
    @lastCaretPosition = @editor.undoManager.currentState()?.caret

    @editor.triggerHandler 'blur'

  _onMouseUp: (e) ->
    unless @editor.util.support.onselectionchange
      @throttledSelectionChanged()

  _onKeyDown: (e) ->
    if @editor.triggerHandler(e) == false
      return false

    # handle predefined shortcuts
    return if @editor.hotkeys.respondTo e

    if @editor.keystroke.respondTo e
      @throttledValueChanged()
      return false

    if e.which in @_modifierKeys or e.which in @_arrowKeys
      return

    # paste shortcut
    return if @editor.util.metaKey(e) and e.which == 86

    unless @editor.util.support.oninput
      @throttledValueChanged ['typing']

    null

  _onKeyPress: (e) ->
    if @editor.triggerHandler(e) == false
      return false

  _onKeyUp: (e) ->
    if @editor.triggerHandler(e) == false
      return false

    if !@editor.util.support.onselectionchange and e.which in @_arrowKeys
      @throttledValueChanged()
      return

    if (e.which == 8 or e.which == 46) && @editor.util.isEmptyNode(@editor.body)
      @editor.body.empty()
      p = $('<p/>').append(@editor.util.phBr)
        .appendTo(@editor.body)
      @editor.selection.setRangeAtStartOf p
      return

  _onDrop: (e) ->
    if @editor.triggerHandler(e) == false
      return false

    @throttledValueChanged()

  _onInput: (e) ->
    @throttledValueChanged ['oninput']
