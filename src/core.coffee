
class Simditor extends Widget
  @connect Util
  @connect UndoManager
  @connect InputManager
  @connect Keystroke
  @connect Formatter
  @connect Selection
  @connect Toolbar

  @count: 0

  opts:
    textarea: null
    placeholder: ''
    defaultImage: 'images/image.png'
    params: {}
    upload: false
    tabIndent: true

  _init: ->
    @textarea = $(@opts.textarea)
    @opts.placeholder = @opts.placeholder ? @textarea.attr('placeholder')

    unless @textarea.length
      throw new Error 'simditor: param textarea is required.'
      return

    editor = @textarea.data 'simditor'
    if editor?
      editor.destroy()

    @id = ++ Simditor.count
    @_render()

    if @opts.upload and simple?.uploader
      uploadOpts = if typeof @opts.upload == 'object' then @opts.upload else {}
      @uploader = simple.uploader(uploadOpts)

    form = @textarea.closest 'form'
    if form.length
      form.on 'submit.simditor-' + @id, =>
        @sync()
      form.on 'reset.simditor-' + @id, =>
        @setValue ''

    # set default value after all plugins are connected
    @on 'pluginconnected', =>
      @setValue @textarea.val() || ''

      if @opts.placeholder
        @on 'valuechanged', =>
          @_placeholder()

      setTimeout =>
        @trigger 'valuechanged'
      , 0

    # Disable the resizing of `img` and `table`
    #if @browser.mozilla
      #document.execCommand "enableObjectResizing", false, "false"
      #document.execCommand "enableInlineTableEditing", false, "false"

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
    @placeholderEl = @wrapper.find('.simditor-placeholder').append(@opts.placeholder)

    @el.append(@textarea)
      .data 'simditor', this
    @textarea.data('simditor', this)
      .hide()
      .blur()
    @body.attr 'tabindex', @textarea.attr('tabindex')

    if @util.os.mac
      @el.addClass 'simditor-mac'
    else if @util.os.linux
      @el.addClass 'simditor-linux'

    if @opts.params
      for key, val of @opts.params
        $('<input/>', {
          type: 'hidden'
          name: key,
          value: val
        }).insertAfter(@textarea)

  _placeholder: ->
    children = @body.children()
    if children.length == 0 or (children.length == 1 and @util.isEmptyNode(children) and (children.data('indent') ? 0) < 1)
      @placeholderEl.show()
    else
      @placeholderEl.hide()

  setValue: (val) ->
    @textarea.val val
    @body.html val

    @formatter.format()
    @formatter.decorate()

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
    while lastP.is('p') and !lastP.text() and !lastP.find('img').length
      emptyP = lastP
      lastP = lastP.prev 'p'
      emptyP.remove()
    while firstP.is('p') and !firstP.text() and !firstP.find('img').length
      emptyP = firstP
      firstP = lastP.next 'p'
      emptyP.remove()

    val = $.trim(cloneBody.html())
    @textarea.val val
    val

  focus: ->
    $blockEl = @body.find('p, li, pre, h1, h2, h3, h4, td').first()
    return unless $blockEl.length > 0
    range = document.createRange()
    @selection.setRangeAtStartOf $blockEl, range
    @body.focus()

  blur: ->
    @body.blur()

  hidePopover: ->
    @wrapper.find('.simditor-popover').each (i, popover) =>
      popover = $(popover).data('popover')
      popover.hide() if popover.active

  destroy: ->
    @triggerHandler 'destroy'

    @textarea.closest('form')
      .off('.simditor .simditor-' + @id)

    @selection.clear()

    @textarea.insertBefore(@el)
      .hide()
      .val('')
      .removeData 'simditor'

    @el.remove()
    $(document).off '.simditor-' + @id
    $(window).off '.simditor-' + @id
    @off()


window.Simditor = Simditor


class TestPlugin extends Plugin

class Test extends Widget
  @connect TestPlugin
