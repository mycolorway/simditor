
class Simditor extends SimpleModule
  @connect Util
  @connect InputManager
  @connect Selection
  @connect UndoManager
  @connect Keystroke
  @connect Formatter
  @connect Toolbar
  @connect Indentation
  @connect Clipboard

  @count: 0

  opts:
    textarea: null
    placeholder: ''
    defaultImage: 'images/image.png'
    params: {}
    upload: false
    indentWidth: 40

  _init: ->
    @textarea = $(@opts.textarea)
    @opts.placeholder = @opts.placeholder || @textarea.attr('placeholder')

    unless @textarea.length
      throw new Error 'simditor: param textarea is required.'
      return

    editor = @textarea.data 'simditor'
    if editor?
      editor.destroy()

    @id = ++ Simditor.count
    @_render()

    if simpleHotkeys
      @hotkeys = simpleHotkeys
        el: @body
    else
      throw new Error 'simditor: simple-hotkeys is required.'
      return

    if @opts.upload and simpleUploader
      uploadOpts = if typeof @opts.upload == 'object' then @opts.upload else {}
      @uploader = simpleUploader(uploadOpts)

    # set default value after all plugins are connected
    @on 'initialized', =>
      if @opts.placeholder
        @on 'valuechanged', =>
          @_placeholder()

      @setValue @textarea.val().trim() || ''

      if @textarea.attr 'autofocus'
        @focus()

    # Disable the resizing of `img` and `table`
    if @util.browser.mozilla
      @util.reflow()
      try
        document.execCommand 'enableObjectResizing', false, false
        document.execCommand 'enableInlineTableEditing', false, false
      catch e

  _tpl:"""
    <div class="simditor">
      <div class="simditor-wrapper">
        <div class="simditor-placeholder"></div>
        <div class="simditor-body" contenteditable="true">
        </div>
      </div>
    </div>
  """

  _render: ->
    @el = $(@_tpl).insertBefore @textarea
    @wrapper = @el.find '.simditor-wrapper'
    @body = @wrapper.find '.simditor-body'
    @placeholderEl = @wrapper.find('.simditor-placeholder')
      .append(@opts.placeholder)

    @el.data 'simditor', @
    @wrapper.append(@textarea)
    @textarea.data('simditor', @).blur()
    @body.attr 'tabindex', @textarea.attr('tabindex')

    if @util.os.mac
      @el.addClass 'simditor-mac'
    else if @util.os.linux
      @el.addClass 'simditor-linux'

    if @util.os.mobile
      @el.addClass 'simditor-mobile'

    if @opts.params
      for key, val of @opts.params
        $('<input/>', {
          type: 'hidden'
          name: key,
          value: val
        }).insertAfter(@textarea)

  _placeholder: ->
    children = @body.children()
    if children.length == 0 or (children.length == 1 and
        @util.isEmptyNode(children) and
        parseInt(children.css('margin-left') || 0) < @opts.indentWidth)
      @placeholderEl.show()
    else
      @placeholderEl.hide()

  setValue: (val) ->
    @hidePopover()
    @textarea.val val
    @body.get(0).innerHTML = if DOMPurify then DOMPurify.sanitize(val) else val

    @formatter.format()
    @formatter.decorate()

    @util.reflow @body
    @inputManager.lastCaretPosition = null
    @trigger 'valuechanged'

  getValue: () ->
    @sync()

  sync: ->
    cloneBody = @body.clone()
    @formatter.undecorate cloneBody
    @formatter.format cloneBody

    # generate `a` tag automatically
    @formatter.autolink cloneBody

    # remove empty `p` tag at the start/end of content
    children = cloneBody.children()
    lastP = children.last 'p'
    firstP = children.first 'p'
    while lastP.is('p') and @util.isEmptyNode(lastP)
      emptyP = lastP
      lastP = lastP.prev 'p'
      emptyP.remove()
    while firstP.is('p') and @util.isEmptyNode(firstP)
      emptyP = firstP
      firstP = lastP.next 'p'
      emptyP.remove()

    # remove images being uploaded
    cloneBody.find('img.uploading').remove()

    val = $.trim(cloneBody.html())
    @textarea.val val
    val

  focus: ->
    unless @body.is(':visible') and @body.is('[contenteditable]')
      @el.find('textarea:visible').focus()
      return

    if @inputManager.lastCaretPosition
      @undoManager.caretPosition @inputManager.lastCaretPosition
      @inputManager.lastCaretPosition = null
    else
      $blockEl = @body.children().last()
      unless $blockEl.is('p')
        $blockEl = $('<p/>').append(@util.phBr).appendTo(@body)
      range = document.createRange()
      @selection.setRangeAtEndOf $blockEl, range

  blur: ->
    if @body.is(':visible') and @body.is('[contenteditable]')
      @body.blur()
    else
      @body.find('textarea:visible').blur()

  hidePopover: ()->
    @el.find('.simditor-popover').each (i, popover) ->
      popover = $(popover).data('popover')
      popover.hide() if popover.active

  destroy: ->
    @triggerHandler 'destroy'

    @textarea.closest('form')
      .off('.simditor .simditor-' + @id)

    @selection.clear()
    @inputManager.focused = false

    @textarea.insertBefore(@el)
      .hide()
      .val('')
      .removeData 'simditor'

    @el.remove()
    $(document).off '.simditor-' + @id
    $(window).off '.simditor-' + @id
    @off()
