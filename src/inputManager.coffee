
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
      # make sure each code block and img has a p following it
      @editor.body.find('pre, .simditor-image').each (i, el) =>
        $el = $(el)
        if ($el.parent().is('blockquote') or $el.parent()[0] == @editor.body[0]) and $el.next().length == 0
          $('<p/>').append(@editor.util.phBr)
            .insertAfter($el)

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
      @addShortcut 'cmd+39', (e) =>
        e.preventDefault()
        @editor.selection.sel.modify('move', 'forward', 'lineboundary')

    if @editor.textarea.attr 'autofocus'
      setTimeout =>
        @editor.focus()
      , 0

  _onFocus: (e) ->
    @editor.el.addClass('focus')
      .removeClass('error')
    @focused = true

    @editor.body.find('.selected').removeClass('selected')

    setTimeout =>
      @editor.triggerHandler 'focus'
      @editor.trigger 'selectionchanged'
    , 0

  _onBlur: (e) ->
    @editor.el.removeClass 'focus'
    @editor.sync()
    @focused = false

    @editor.triggerHandler 'blur'

  _onMouseUp: (e) ->
    return if $(e.target).is('img, .simditor-image')
    @editor.trigger 'selectionchanged'

  _onKeyDown: (e) ->
    if @editor.triggerHandler(e) == false
      return false

    # handle predefined shortcuts
    shortcutKey = @editor.util.getShortcutKey e
    if @_shortcuts[shortcutKey]
      @_shortcuts[shortcutKey].call(this, e)
      return false

    if e.which in @_modifierKeys or e.which in @_arrowKeys
      return

    metaKey = @editor.util.metaKey e
    $blockEl = @editor.util.closestBlockEl()

    # paste shortcut
    return if metaKey and e.which == 86

    # Check the condictional handlers
    if e.which of @_inputHandlers
      result = null
      @editor.util.traverseUp (node) =>
        return unless node.nodeType == 1
        handler = @_inputHandlers[e.which]?[node.tagName.toLowerCase()]
        result = handler?.call(@, e, $(node))
        !result
      if result
        @editor.trigger 'valuechanged'
        @editor.trigger 'selectionchanged'
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
    if e.which == 9
      if e.shiftKey
        @outdent()
      else
        @indent()
      return false

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
          imageFile.name = "来自剪贴板的图片.png";

        uploadOpt = {}
        uploadOpt[@opts.pasteImage] = true
        @editor.uploader?.upload(imageFile, uploadOpt)
        return false


    $blockEl = @editor.util.closestBlockEl()
    codePaste = $blockEl.is 'pre'
    @editor.selection.deleteRangeContents()
    @editor.selection.save()

    @_pasteArea.focus()

    setTimeout =>
      if @_pasteArea.is(':empty')
        pasteContent = null
      else if codePaste
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
      else if codePaste
        node = document.createTextNode(pasteContent)
        @editor.selection.insertNode node, range
      else if pasteContent.length < 1
        return
      else if pasteContent.length == 1
        if pasteContent.is('p')
          children = pasteContent.contents()
          @editor.selection.insertNode node for node in children

        # paste image in firefox
        else if pasteContent.is('.simditor-image')
          $img = pasteContent.find('img')

          # firefox
          if dataURLtoBlob && $img.is('img[src^="data:image/png;base64"]')
            return unless @opts.pasteImage
            blob = dataURLtoBlob $img.attr( "src" )
            blob.name = "来自剪贴板的图片.png"

            uploadOpt = {}
            uploadOpt[@opts.pasteImage] = true
            @editor.uploader?.upload(blob, uploadOpt)
            return

          # cannot paste image in safari
          else if imgEl.is('img[src^="webkit-fake-url://"]')
            return
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
  _inputHandlers:
    13: # enter

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

        range.collapse(false)
        @editor.selection.selectRange(range)
        true

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

        range.collapse(false)
        @editor.selection.selectRange range
        true

      # press enter in the last paragraph of blockquote, just leave the block quote
      blockquote: (e, $node) ->
        $closestBlock = @editor.util.closestBlockEl()
        return unless $closestBlock.is('p') and !$closestBlock.next().length and @editor.util.isEmptyNode $closestBlock
        $node.after $closestBlock
        @editor.selection.setRangeAtStartOf $closestBlock
        true

    8: # backspace
      pre: (e, $node) ->
        return unless @editor.selection.rangeAtStartOf $node
        codeStr = $node.html().replace('\n', '<br/>')
        $newNode = $('<p/>').append(codeStr || @editor.util.phBr).insertAfter $node
        $node.remove()
        @editor.selection.setRangeAtStartOf $newNode
        true

      blockquote: (e, $node) ->
        return unless @editor.selection.rangeAtStartOf $node
        $firstChild = $node.children().first().unwrap()
        @editor.selection.setRangeAtStartOf $firstChild
        true

  # a hook will be triggered when specific string was typed
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

  addShortcut: (keys, handler) ->
    @_shortcuts[keys] = $.proxy(handler, this)

  indent: () ->
    $blockEl = @editor.util.closestBlockEl()
    return unless $blockEl and $blockEl.length > 0

    if $blockEl.is('pre')
      spaceNode = document.createTextNode '\u00A0\u00A0'
      @editor.selection.insertNode spaceNode
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
    else if $blockEl.is('p, h1, h2, h3, h4')
      indentLevel = $blockEl.attr('data-indent') ? 0
      indentLevel = indentLevel * 1 + 1
      indentLevel = 10 if indentLevel > 10
      $blockEl.attr 'data-indent', indentLevel
    else
      spaceNode = document.createTextNode '\u00A0\u00A0\u00A0\u00A0'
      @editor.selection.insertNode spaceNode

    @editor.trigger 'valuechanged'
    @editor.trigger 'selectionchanged'

  outdent: () ->
    $blockEl = @editor.util.closestBlockEl()
    return unless $blockEl and $blockEl.length > 0

    if $blockEl.is('pre')
      # TODO: outdent in code block
      return
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
    else if $blockEl.is('p, h1, h2, h3, h4')
      indentLevel = $blockEl.attr('data-indent') ? 0
      indentLevel = indentLevel * 1 - 1
      indentLevel = 0 if indentLevel < 0
      $blockEl.attr 'data-indent', indentLevel
    else
      return

    @editor.trigger 'valuechanged'
    @editor.trigger 'selectionchanged'





