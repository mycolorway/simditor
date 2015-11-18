
class Popover extends SimpleModule

  offset:
    top: 4
    left: 0

  target: null

  active: false

  constructor: (opts) ->
    @button = opts.button
    @editor = opts.button.editor
    super opts

  _init: ->
    @el = $('<div class="simditor-popover"></div>')
      .appendTo(@editor.el)
      .data('popover', @)
    @render()

    @el.on 'mouseenter', (e) =>
      @el.addClass 'hover'
    @el.on 'mouseleave', (e) =>
      @el.removeClass 'hover'

  render: ->

  _initLabelWidth: ->
    $fields = @el.find '.settings-field'
    return unless $fields.length > 0

    @_labelWidth = 0
    $fields.each (i, field) =>
      $field = $ field
      $label = $field.find 'label'
      return unless $label.length > 0
      @_labelWidth = Math.max @_labelWidth, $label.width()

    $fields.find('label').width @_labelWidth

  show: ($target, position = 'bottom') ->
    return unless $target?

    # hide other popovers
    @el.siblings('.simditor-popover').each (i, popover) ->
      popover = $(popover).data('popover')
      popover.hide() if popover.active

    @target.removeClass('selected') if @active and @target
    @target = $target.addClass('selected')

    if @active
      @refresh(position)
      @trigger 'popovershow'
    else
      @active = true

      @el.css({
        left: -9999
      }).show()

      @_initLabelWidth() unless @_labelWidth

      @editor.util.reflow()
      @refresh(position)
      @trigger 'popovershow'

  hide: ->
    return unless @active
    @target.removeClass('selected') if @target
    @target = null
    @active = false
    @el.hide()
    @trigger 'popoverhide'

  refresh: (position = 'bottom') ->
    return unless @active
    editorOffset = @editor.el.offset()
    targetOffset = @target.offset()
    targetH = @target.outerHeight()

    if position is 'bottom'
      top = targetOffset.top - editorOffset.top + targetH
    else if position is 'top'
      top = targetOffset.top - editorOffset.top - @el.height()

    maxLeft = @editor.wrapper.width() - @el.outerWidth() - 10
    left = Math.min(targetOffset.left - editorOffset.left, maxLeft)

    @el.css({
      top: top + @offset.top,
      left: left + @offset.left
    })

  destroy: () ->
    @target = null
    @active = false
    @editor.off('.linkpopover')
    @el.remove()

  _t: (args...) ->
    result = super args...
    result = @button._t args... unless result
    result


Simditor.Popover = Popover
