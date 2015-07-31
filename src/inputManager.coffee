
class InputManager extends SimpleModule

  @pluginName: 'InputManager'

  opts:
    pasteImage: false

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

    if @opts.pasteImage and typeof @opts.pasteImage != 'string'
      @opts.pasteImage = 'inline'

    # handlers which will be called
    # when specific key is pressed in specific node
    @_keystrokeHandlers = {}

    @hotkeys = simpleHotkeys
      el: @editor.body

    @_pasteArea = $('<div/>')
      .css({
        width: '1px',
        height: '1px',
        overflow: 'hidden',
        position: 'fixed',
        right: '0',
        bottom: '100px'
      })
      .attr({
        tabIndex: '-1',
        contentEditable: true
      })
      .addClass('simditor-paste-area')
      .appendTo(@editor.el)

    $(document).on 'selectionchange.simditor' + @editor.id, (e) =>
      return unless @focused
      @throttledSelectionChanged()

    @editor.on 'valuechanged', =>
      @lastCaretPosition = null

      if @focused and !@editor.selection.blockNodes().length
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
      .on('paste', $.proxy(@_onPaste, @))
      .on('drop', $.proxy(@_onDrop, @))
      .on 'input', $.proxy @_onInput, @

    if @editor.util.browser.firefox
      # fix firefox cmd+left/right bug
      @addShortcut 'cmd+left', (e) =>
        e.preventDefault()
        @editor.selection._selection.modify('move', 'backward', 'lineboundary')
        false
      @addShortcut 'cmd+right', (e) =>
        e.preventDefault()
        @editor.selection._selection.modify('move', 'forward', 'lineboundary')
        false

      # override default behavior of cmd/ctrl + a in firefox(which is buggy)
      @addShortcut (if @editor.util.os.mac then 'cmd+a' else 'ctrl+a'), (e) =>
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
    @addShortcut submitKey, (e) =>
      @editor.el.closest('form')
        .find('button:submit')
        .click()
      false

    if @editor.textarea.attr 'autofocus'
      setTimeout =>
        @editor.focus()
      , 0


  _onFocus: (e) ->
    @editor.el.addClass('focus')
      .removeClass('error')
    @focused = true
    @lastCaretPosition = null

    setTimeout =>
      @editor.triggerHandler 'focus'
      @throttledSelectionChanged() unless @editor.util.support.onselectionchange
    , 0

  _onBlur: (e) ->
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
    return if @hotkeys.respondTo e

    # Check the condictional handlers
    if e.which of @_keystrokeHandlers
      result = @_keystrokeHandlers[e.which]['*']?(e)
      if result
        @throttledValueChanged()
        return false

      @editor.selection.startNodes().each (i, node) =>
        return unless node.nodeType == Node.ELEMENT_NODE
        handler = @_keystrokeHandlers[e.which]?[node.tagName.toLowerCase()]
        result = handler?(e, $(node))

        # different result means:
        # 1. true, handler done, stop browser default action and traverse up
        # 2. false, stop traverse up
        # 3. undefined, continue traverse up
        false if result == true or result == false

      if result
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

  _onPaste: (e) ->
    if @editor.triggerHandler(e) == false
      return false

    range = @editor.selection.deleteRangeContents()
    range.collapse(true) unless range.collapsed
    @editor.selection.range range
    $blockEl = @editor.selection.blockNodes().last()
    cleanPaste = $blockEl.is 'pre, table'

    if e.originalEvent.clipboardData && e.originalEvent.clipboardData.items &&
        e.originalEvent.clipboardData.items.length > 0
      pasteItem = e.originalEvent.clipboardData.items[0]

      # paste file in chrome
      if /^image\//.test(pasteItem.type) and !cleanPaste
        imageFile = pasteItem.getAsFile()
        return unless imageFile? and @opts.pasteImage

        unless imageFile.name
          imageFile.name = "Clipboard Image.png"

        uploadOpt = {}
        uploadOpt[@opts.pasteImage] = true
        @editor.uploader?.upload(imageFile, uploadOpt)
        return false

    processPasteContent = (pasteContent) =>
      if @editor.triggerHandler('pasting', [pasteContent]) == false
        return

      if !pasteContent
        return
      else if cleanPaste
        if $blockEl.is('table')
          lines = pasteContent.split('\n')
          lastLine = lines.pop()
          for line in lines
            @editor.selection.insertNode document.createTextNode(line)
            @editor.selection.insertNode $('<br/>')
          @editor.selection.insertNode document.createTextNode(lastLine)
        else
          pasteContent = $('<div/>').text(pasteContent)
          for node in pasteContent.contents()
            @editor.selection.insertNode($(node)[0], range)
      else if $blockEl.is @editor.body
        @editor.selection.insertNode(node, range) for node in pasteContent
      else if pasteContent.length < 1
        return
      else if pasteContent.length == 1
        if pasteContent.is('p')
          children = pasteContent.contents()

          if children.length == 1 and children.is('img')
            $img = children

            # paste image in firefox and IE 11
            if /^data:image/.test($img.attr('src'))
              return unless @opts.pasteImage
              blob = @editor.util.dataURLtoBlob $img.attr( "src" )
              blob.name = "Clipboard Image.png"

              uploadOpt = {}
              uploadOpt[@opts.pasteImage] = true
              @editor.uploader?.upload(blob, uploadOpt)
              return

            # cannot paste image in safari
            else if $img.is('img[src^="webkit-fake-url://"]')
              return

          @editor.selection.insertNode(node, range) for node in children

        else if $blockEl.is('p') and @editor.util.isEmptyNode $blockEl
          $blockEl.replaceWith pasteContent
          @editor.selection.setRangeAtEndOf(pasteContent, range)
        else if pasteContent.is('ul, ol')
          if pasteContent.find('li').length == 1
            pasteContent = $('<div/>').text(pasteContent.text())
            for node in pasteContent.contents()
              @editor.selection.insertNode($(node)[0], range)
          else if $blockEl.is 'li'
            $blockEl.parent().after pasteContent
            @editor.selection.setRangeAtEndOf(pasteContent, range)
          else
            $blockEl.after pasteContent
            @editor.selection.setRangeAtEndOf(pasteContent, range)
        else
          $blockEl.after pasteContent
          @editor.selection.setRangeAtEndOf(pasteContent, range)
      else
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

      @throttledValueChanged()

    if cleanPaste
      e.preventDefault()
      if @editor.util.browser.msie
        pasteContent = window.clipboardData.getData('Text')
      else
        pasteContent = e.originalEvent.clipboardData.getData('text/plain')
      processPasteContent pasteContent
    else
      @editor.selection.save range
      @_pasteArea.focus()

      # IE10 cannot set focus on textarea or editable div before pasting
      if @editor.util.browser.msie and @editor.util.browser.version == 10
        e.preventDefault()
        @_pasteArea.html window.clipboardData.getData('Text')

      setTimeout =>
        if @_pasteArea.is(':empty')
          pasteContent = null
        else
          pasteContent = $('<div/>').append(@_pasteArea.contents())
          pasteContent.find('table colgroup').remove() # clear table cols width
          @editor.formatter.format pasteContent
          @editor.formatter.decorate pasteContent
          @editor.formatter.beautify pasteContent.children()
          pasteContent = pasteContent.contents()

        @_pasteArea.empty()
        range = @editor.selection.restore()
        processPasteContent pasteContent
      , 10

  _onDrop: (e) ->
    if @editor.triggerHandler(e) == false
      return false

    @throttledValueChanged()

  _onInput: (e) ->
    @throttledValueChanged ['oninput']

  addKeystrokeHandler: (key, node, handler) ->
    @_keystrokeHandlers[key] = {} unless @_keystrokeHandlers[key]
    @_keystrokeHandlers[key][node] = handler


  addShortcut: (keys, handler) ->
    @hotkeys.add keys, $.proxy(handler, @)
