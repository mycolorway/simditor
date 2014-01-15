
class Simditor extends Widget
  @extend Util
  @extend Input
  @extend Format
  @extend Selection

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

    # Disable the resizing of `img` and `table`
    #if @browser.mozilla
      #document.execCommand "enableObjectResizing", false, "false"
      #document.execCommand "enableInlineTableEditing", false, "false"

  _tpl:"""
    <div class="simditor">
      <div class="simditor-wrapper">
        <div class="simditor-body" contenteditable="true">
        </div>
      </div>
    </div>
  """

  _render: ->
    @el = $(@_tpl).insertBefore @textarea
    @wrapper = @el.find '.simditor-wrapper'
    @body = @wrapper.find '.simditor-body'

    @el.append(@textarea)
      .data 'simditor', this
    @textarea.data('simditor', this)
      .hide()
      .blur()
    @body.attr 'tabindex', @textarea.attr('tabindex')

  setValue: (val) ->
    @textarea.val val
    @body.html val

    @format()
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


window.simditor = (opts) ->
  return new Simditor opts
