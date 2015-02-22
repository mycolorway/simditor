
class SourceButton extends Button

  name: 'source'

  icon: 'html5'

  needFocus: false

  _init: ->
    super()

    @editor.textarea.on 'focus', (e) =>
      @editor.el.addClass('focus')
        .removeClass('error')

    @editor.textarea.on 'blur', (e) =>
      @editor.el.removeClass 'focus'
      @editor.setValue @editor.textarea.val()

    @editor.textarea.on 'input', (e) =>
      @_resizeTextarea()

  status: ($node) ->
    true

  command: ->
    @editor.blur()
    @editor.el.toggleClass 'simditor-source-mode'
    @editor.sourceMode = @editor.el.hasClass 'simditor-source-mode'

    if @editor.sourceMode
      @editor.hidePopover()
      @editor.textarea.val @editor.util.formatHTML(@editor.textarea.val())
      @_resizeTextarea()

    for button in @editor.toolbar.buttons
      if button.name == 'source'
        button.setActive @editor.sourceMode
      else
        button.setDisabled @editor.sourceMode

    null

  _resizeTextarea: ->
    @_textareaPadding ||= @editor.textarea.innerHeight() - @editor.textarea.height()
    @editor.textarea.height(0)
      .height (@editor.textarea[0].scrollHeight - @_textareaPadding)

Simditor.Toolbar.addButton SourceButton

