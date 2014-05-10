
class InputManager extends Plugin

  @className: 'InputManager'

  opts:
    pasteImage: false

  constructor: (args...) ->
    super args...
    @editor = @widget
    @opts.pasteImage = 'inline' if @opts.pasteImage and typeof @opts.pasteImage != 'string'

  _modifierKeys: [16, 17, 18, 91, 93, 224]

  _arrowKeys: [37..40]

  _init: ->
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

    @editor.on 'valuechanged', =>
      # make sure each code block, img and table has siblings
      @editor.body.find('hr, pre, .simditor-image, .simditor-table').each (i, el) =>
        $el = $(el)
        if ($el.parent().is('blockquote') or $el.parent()[0] == @editor.body[0])
          if $el.next().length == 0
            $('<p/>').append(@editor.util.phBr)
              .insertAfter($el)
          if $el.prev().length == 0
            $('<p/>').append(@editor.util.phBr)
              .insertBefore($el)

          setTimeout =>
            @editor.trigger 'valuechanged'
          , 10


    @editor.body.on('keydown', $.proxy(@_onKeyDown, @))
      .on('keypress', $.proxy(@_onKeyPress, @))
      .on('keyup', $.proxy(@_onKeyUp, @))
      .on('mouseup', $.proxy(@_onMouseUp, @))
      .on('focus', $.proxy(@_onFocus, @))
      .on('blur', $.proxy(@_onBlur, @))
      .on('paste', $.proxy(@_onPaste, @))

    # fix firefox cmd+left/right bug
    if @editor.util.browser.firefox
      @addShortcut 'cmd+37', (e) =>
        e.preventDefault()
        @editor.selection.sel.modify('move', 'backward', 'lineboundary')
        false
      @addShortcut 'cmd+39', (e) =>
        e.preventDefault()
        @editor.selection.sel.modify('move', 'forward', 'lineboundary')
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

    @editor.body.find('.selected').removeClass('selected')

    setTimeout =>
      @editor.triggerHandler 'focus'
      #@editor.trigger 'selectionchanged'
    , 0

  _onBlur: (e) ->
    @editor.el.removeClass 'focus'
    @editor.sync()
    @focused = false
    @lastCaretPosition = @editor.undoManager.currentState()?.caret

    @editor.triggerHandler 'blur'

  _onMouseUp: (e) ->
    return if $(e.target).is('img, .simditor-image')
    @editor.trigger 'selectionchanged'
    @editor.undoManager.update()

  _onKeyDown: (e) ->
    if @editor.triggerHandler(e) == false
      return false

    # handle predefined shortcuts
    shortcutKey = @editor.util.getShortcutKey e
    if @_shortcuts[shortcutKey]
      return @_shortcuts[shortcutKey].call(this, e)

    # Check the condictional handlers
    if e.which of @_keystrokeHandlers
      result = @_keystrokeHandlers[e.which]['*']?(e)
      if result
        @editor.trigger 'valuechanged'
        @editor.trigger 'selectionchanged'
        return false

      @editor.util.traverseUp (node) =>
        return unless node.nodeType == 1
        handler = @_keystrokeHandlers[e.which]?[node.tagName.toLowerCase()]
        result = handler?(e, $(node))
        !result
      if result
        @editor.trigger 'valuechanged'
        @editor.trigger 'selectionchanged'
        return false

    if e.which in @_modifierKeys or e.which in @_arrowKeys
      return

    metaKey = @editor.util.metaKey e
    $blockEl = @editor.util.closestBlockEl()

    # paste shortcut
    return if metaKey and e.which == 86

    if @_typing
      clearTimeout @_typing if @_typing != true
      @_typing = setTimeout =>
        @editor.trigger 'valuechanged'
        @editor.trigger 'selectionchanged'
        @_typing = false
      , 200
    else
      setTimeout =>
        @editor.trigger 'valuechanged'
        @editor.trigger 'selectionchanged'
      , 10
      @_typing = true

    null

  _onKeyPress: (e) ->
    if @editor.triggerHandler(e) == false
      return false

    # input hooks are limited in a single line
    @_hookStack.length = 0 if e.which == 13

    # check the input hooks
    if e.which == 32
      cmd = @_hookStack.join ''
      @_hookStack.length = 0

      for hook in @_inputHooks
        if (hook.cmd instanceof RegExp and hook.cmd.test(cmd)) or hook.cmd == cmd
          hook.callback(e, hook, cmd)
          break
    else if @_hookKeyMap[e.which]
      @_hookStack.push @_hookKeyMap[e.which]
      @_hookStack.shift() if @_hookStack.length > 10

  _onKeyUp: (e) ->
    if @editor.triggerHandler(e) == false
      return false

    if e.which in @_arrowKeys
      @editor.trigger 'selectionchanged'
      @editor.undoManager.update()
      return

    if e.which == 8 and (@editor.body.is(':empty') or (@editor.body.children().length == 1 and @editor.body.children().is('br')))
      @editor.body.empty()
      p = $('<p/>').append(@editor.util.phBr)
        .appendTo(@editor.body)
      @editor.selection.setRangeAtStartOf p
      return

  _onPaste: (e) ->
    if @editor.triggerHandler(e) == false
      return false

    if e.originalEvent.clipboardData && e.originalEvent.clipboardData.items && e.originalEvent.clipboardData.items.length > 0
      pasteItem = e.originalEvent.clipboardData.items[0]

      # paste file in chrome
      if /^image\//.test pasteItem.type
        imageFile = pasteItem.getAsFile()
        return unless imageFile? and @opts.pasteImage

        unless imageFile.name
          imageFile.name = "来自剪贴板的图片.png"

        uploadOpt = {}
        uploadOpt[@opts.pasteImage] = true
        @editor.uploader?.upload(imageFile, uploadOpt)
        return false

    range = @editor.selection.deleteRangeContents()
    range.collapse(true) unless range.collapsed

    $blockEl = @editor.util.closestBlockEl()
    cleanPaste = $blockEl.is 'pre, table'
    @editor.selection.save range

    @_pasteArea.focus()

    setTimeout =>
      if @_pasteArea.is(':empty')
        pasteContent = null
      else if cleanPaste
        pasteContent = @editor.formatter.clearHtml @_pasteArea.html()
      else
        pasteContent = $('<div/>').append(@_pasteArea.contents())
        @editor.formatter.format pasteContent
        @editor.formatter.decorate pasteContent
        @editor.formatter.beautify pasteContent.children()
        pasteContent = pasteContent.contents()

      @_pasteArea.empty()
      range = @editor.selection.restore()

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
          @editor.selection.insertNode($(node)[0], range) for node in pasteContent.contents()
      else if $blockEl.is @editor.body
        @editor.selection.insertNode(node, range) for node in pasteContent
      else if pasteContent.length < 1
        return
      else if pasteContent.length == 1
        if pasteContent.is('p')
          children = pasteContent.contents()
          @editor.selection.insertNode(node, range) for node in children

        # paste image in firefox and IE 11
        else if pasteContent.is('.simditor-image')
          $img = pasteContent.find('img')

          # firefox and IE 11
          if /^data:image/.test($img.attr('src'))
            return unless @opts.pasteImage
            blob = @editor.util.dataURLtoBlob $img.attr( "src" )
            blob.name = "来自剪贴板的图片.png"

            uploadOpt = {}
            uploadOpt[@opts.pasteImage] = true
            @editor.uploader?.upload(blob, uploadOpt)
            return

          # cannot paste image in safari
          else if $img.is('img[src^="webkit-fake-url://"]')
            return
        else if $blockEl.is('p') and @editor.util.isEmptyNode $blockEl
          $blockEl.replaceWith pasteContent
          @editor.selection.setRangeAtEndOf(pasteContent, range)
        else if pasteContent.is('ul, ol') and $blockEl.is 'li'
          $blockEl.parent().after pasteContent
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

      @editor.trigger 'valuechanged'
      @editor.trigger 'selectionchanged'
    , 10


  # handlers which will be called when specific key is pressed in specific node
  _keystrokeHandlers: {}

  addKeystrokeHandler: (key, node, handler) ->
    @_keystrokeHandlers[key] = {} unless @_keystrokeHandlers[key]
    @_keystrokeHandlers[key][node] = handler


  # a hook will be triggered when specific string typed
  _inputHooks: []

  _hookKeyMap: {}

  _hookStack: []

  addInputHook: (hookOpt) ->
    $.extend(@_hookKeyMap, hookOpt.key)
    @_inputHooks.push hookOpt


  _shortcuts:
    # meta + enter: submit form
    'cmd+13': (e) ->
      @editor.el.closest('form')
        .find('button:submit')
        .click()
      false

  addShortcut: (keys, handler) ->
    @_shortcuts[keys] = $.proxy(handler, this)






