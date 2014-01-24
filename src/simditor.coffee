
class Simditor extends Widget
  @connect Util
  @connect UndoManager
  @connect InputManager
  @connect Formatter
  @connect Selection
  @connect Toolbar

  @count: 0

  opts:
    textarea: null
    placeholder: 'Type here...'

  _init: ->
    @textarea = $(@opts.textarea);

    unless @textarea.length
      throw new Error 'simditor: param textarea is required.'
      return

    editor = @textarea.data 'simditor'
    if editor?
      editor.destroy()

    @id = ++ Simditor.count
    @_render()

    form = @textarea.closest 'form'
    if form.length
      form.on 'submit.simditor-' + @id, =>
        @sync()
      form.on 'reset.simditor-' + @id, =>
        @setValue ''

    if val = @textarea.val()
      @setValue val ? ''
      setTimeout =>
        @trigger 'valuechanged'
      , 0

    @on 'valuechanged', =>
      @_placeholder()

    @_placeholder()

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

  _placeholder: ->
    children = @body.children()
    if children.length == 0 or (children.length == 1 and @util.isEmptyNode(children))
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
    val = @formatter.undecorate()
    @textarea.val val
    val

  destroy: ->
    @trigger('destroy')

    @textarea.closest 'form'
      .off '.simditor .simditor-' + @id

    @selection.clear()

    @textarea.insertBefore(@el)
      .hide()
      .val ''
      .removeData 'simditor'

    @el.remove()
    $(document).off '.simditor-' + @id
    $(window).off '.simditor-' + @id


window.Simditor = Simditor
window.Simditor.Plugin = Plugin
