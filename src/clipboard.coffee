
class Clipboard extends SimpleModule

  @pluginName: 'Clipboard'

  opts:
    pasteImage: false
    cleanPaste: false

  _init: ->
    @editor = @_module

    if @opts.pasteImage and typeof @opts.pasteImage != 'string'
      @opts.pasteImage = 'inline'

    @editor.body.on 'paste', (e) =>
      return if @pasting or @_pasteBin

      if @editor.triggerHandler(e) == false
        return false

      range = @editor.selection.deleteRangeContents()
      if @editor.body.html()
        range.collapse(true) unless range.collapsed
      else
        @editor.formatter.format()
        @editor.selection.setRangeAtStartOf @editor.body.find('p:first')
        range = @editor.selection._range

      return false if @_processPasteByClipboardApi(e)

      pasteBinAnchor = $('<span>')
      range.insertNode(pasteBinAnchor[0])
      @_createPasteBin pasteBinAnchor
      pasteBinAnchor.remove()
      range.collapse(true)
      @editor.selection.range range

      @editor.inputManager.throttledValueChanged.clear()
      @editor.inputManager.throttledSelectionChanged.clear()
      @editor.undoManager.throttledPushState.clear()
      @editor.selection.reset()
      @editor.undoManager.resetCaretPosition()

      @pasting = true

      @_getPasteContent (pasteContent) =>
        @_processPasteContent pasteContent
        @_pasteInBlockEl = null
        @_pastePlainText = null
        @pasting = false

  _processPasteByClipboardApi: (e) ->
    # paste file in chrome
    if e.originalEvent.clipboardData && e.originalEvent.clipboardData.items &&
        e.originalEvent.clipboardData.items.length > 0
      pasteItem = e.originalEvent.clipboardData.items[0]

      if /^image\//.test(pasteItem.type)
        imageFile = pasteItem.getAsFile()
        return unless imageFile? and @opts.pasteImage

        unless imageFile.name
          imageFile.name = "Clipboard Image.png"

        return if @editor.triggerHandler('pasting', [imageFile]) == false

        uploadOpt = {}
        uploadOpt[@opts.pasteImage] = true
        @editor.uploader?.upload(imageFile, uploadOpt)
        return true

  _createPasteBin: (anchorNode) ->
    anchorOffset = anchorNode.offset()
    editorOffset  = @editor.el.offset()
    @_pasteBin = $ '<div contenteditable="true" />'
      .addClass 'simditor-paste-bin'
      .attr 'tabIndex', '-1'
      .css({
        top: anchorOffset.top - editorOffset.top
        left: anchorOffset.left - editorOffset.left
      })
      .appendTo @editor.el

  _getPasteContent: (callback) ->
    state =
      html: @editor.body.html()
      caret: @editor.undoManager.caretPosition()

    @_pasteBin.focus()

    setTimeout =>
      @editor.hidePopover()
      @editor.body.get(0).innerHTML = if DOMPurify then DOMPurify.sanitize(state.html) else state.html
      @editor.undoManager.caretPosition state.caret
      @editor.body.focus()
      @editor.selection.reset()
      @editor.selection.range()

      @_pasteInBlockEl = @editor.selection.blockNodes().last()
      @_pastePlainText = @opts.cleanPaste || @_pasteInBlockEl.is('pre, table')

      if @_pastePlainText
        pasteContent = @editor.formatter.clearHtml @_pasteBin.html(), true
      else
        pasteContent = $('<div/>').append(@_pasteBin.contents())
        pasteContent.find('style').remove() # clear style tag
        pasteContent.find('table colgroup').remove() # clear table cols width
        @_cleanPasteFontSize pasteContent
        @editor.formatter.format pasteContent
        @editor.formatter.decorate pasteContent
        @editor.formatter.beautify pasteContent.children()

        pasteContent = pasteContent.contents()

      @_pasteBin.remove()
      @_pasteBin = null
      callback pasteContent
    , 0

  _processPasteContent: (pasteContent) ->
    return if @editor.triggerHandler('pasting', [pasteContent]) == false
    $blockEl = @_pasteInBlockEl

    if !pasteContent
      return

    if @_pastePlainText
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
          @editor.selection.insertNode($(node)[0])
    else if $blockEl.is @editor.body
      @editor.selection.insertNode(node) for node in pasteContent
    else if pasteContent.length < 1
      return
    else if pasteContent.length == 1
      if pasteContent.is('p')
        children = pasteContent.contents()

        if $blockEl.is 'h1, h2, h3, h4, h5'
          if children.length
            children.css('font-size', '')

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

          else if new RegExp('^blob:' + location.origin + '/').test($img.attr('src'))
            return unless @opts.pasteImage
            uploadOpt = {}
            uploadOpt[@opts.pasteImage] = true
            dataURLtoBlob = @editor.util.dataURLtoBlob
            uploader = @editor.uploader
            img = new Image

            img.onload = ->
              canvas = document.createElement('canvas')
              canvas.width = img.naturalWidth
              canvas.height = img.naturalHeight
              canvas.getContext('2d').drawImage img, 0, 0
              blob = dataURLtoBlob(canvas.toDataURL('image/png'))
              blob.name = 'Clipboard Image.png'
              if uploader != null
                uploader.upload blob, uploadOpt
              return

            img.src = $img.attr('src')
            return

          # cannot paste image in safari
          else if $img.is('img[src^="webkit-fake-url://"]')
            return

        @editor.selection.insertNode(node) for node in children

      else if $blockEl.is('p') and @editor.util.isEmptyNode $blockEl
        $blockEl.replaceWith pasteContent
        @editor.selection.setRangeAtEndOf(pasteContent)
      else if pasteContent.is('ul, ol')
        if pasteContent.find('li').length == 1
          pasteContent = $('<div/>').text(pasteContent.text())
          for node in pasteContent.contents()
            @editor.selection.insertNode($(node)[0])
        else if $blockEl.is 'li'
          $blockEl.parent().after pasteContent
          @editor.selection.setRangeAtEndOf(pasteContent)
        else
          $blockEl.after pasteContent
          @editor.selection.setRangeAtEndOf(pasteContent)
      else
        $blockEl.after pasteContent
        @editor.selection.setRangeAtEndOf(pasteContent)
    else
      $blockEl = $blockEl.parent() if $blockEl.is 'li'

      if @editor.selection.rangeAtStartOf($blockEl)
        insertPosition = 'before'
      else if @editor.selection.rangeAtEndOf($blockEl)
        insertPosition = 'after'
      else
        @editor.selection.breakBlockEl($blockEl)
        insertPosition = 'before'

      $blockEl[insertPosition](pasteContent)
      @editor.selection.setRangeAtEndOf(pasteContent.last())

    @editor.inputManager.throttledValueChanged()

  _cleanPasteFontSize: (node) ->
    $node = $(node)
    return unless $node.length > 0

    sizeMap = [
      '1.5em'
      '1.25em'
      '0.75em'
      '0.5em'
    ]

    $node.find('[style*="font-size"]')
      .map (i, el) ->
        $el = $(el)
        if $.inArray($el.css('font-size'), sizeMap) < 0
          $el.css('font-size', '')
