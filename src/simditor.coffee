
class Simditor extends Widget
  @extend Simditor.Util
  @extend Simditor.Input
  @extend Simditor.Format
  @extend Simditor.Selection

  @count: 0

  opts:
    textarea: null

  _init: ->
    @textarea = $(@opts.textarea);

    unless @textarea.length
      throw new Error 'simditor: param textarea is required.'
      return

    editor = @textarea.data 'simditor'
    if editor?
      editor.destroy()

    @id = ++ Simditor.count
    @textarea.hide().blur()

    form = @textarea.closest 'form'
    if form.length
      form
        .on 'submit.simditor-' + @id, =>
          @sync()
        .on 'reset.simditor-' + @id, =>
          @setValue ''

    if val = @textarea.val()
      @setValue val
      setTimeout =>
        @trigger 'valuechanged'
      , 0

    # Disable the resizing of `img` and `table`
    if @browser.mozilla
      document.execCommand "enableObjectResizing", false, "false"
      document.execCommand "enableInlineTableEditing", false, "false"

  _tpl:"""
    <div class="simditor">
      <div class="simditor-wrapper">
        <div class="simditor-body" contenteditable="true">
        </div>
      </div>
    </div>
  """

  _render: ->
    @el = $(@_tpl)
    @wrapper = @el.find '.simditor-wrapper'
    @body = @wrapper.find '.simditor-body'

    @el.data 'simditor', this
    @textarea.data 'simditor', this
    @body.attr 'tabindex', @textarea.attr('tabindex')

  setValue: (val) ->
    @textarea.val val
    @body.html val
    @_decorate()

  getValue: () ->
    @sync()

  sync: ->
    val = @_undecorate()
    @textarea.val val
    val

  destroy: ->
    @trigger('destroy')

    @textarea.closest 'form'
      .off '.simditor simditor-' + @id

    @sel.removeAllRanges()

    @textarea.insertBefore(@el)
      .hide()
      .val ''
      .removeData 'simditor'

    @el.remove()

