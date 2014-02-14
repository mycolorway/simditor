
class Popover extends Module

  offset:
    top: 4
    left: 0

  target: null

  active: false

  constructor: (@editor) ->
    @el = $('<div class="simditor-popover"></div>')
      .appendTo(@editor.wrapper)
    @render()

    @editor.on 'blur.linkpopover', =>
      @target.addClass('selected') if @active and @target?

  render: ->

  show: ($target, position = 'bottom') ->
    return unless $target?
    @target = $target
    @active = true

    @el.css({
      left: -9999
    }).show()

    setTimeout =>
      @refresh(position)
      @trigger 'popovershow'
    , 0

  hide: ->
    @target = null
    @active = false
    @el.hide()
    @trigger 'popoverhide'

  refresh: (position = 'bottom') ->
    wrapperOffset = @editor.wrapper.offset()
    targetOffset = @target.offset()
    targetH = @target.outerHeight()

    if position is 'bottom'
      top = targetOffset.top - wrapperOffset.top + targetH
    else if position is 'top'
      top = targetOffset.top - wrapperOffset.top - @el.height()

    left = Math.min(targetOffset.left - wrapperOffset.left, @editor.wrapper.width() - @el.outerWidth() - 10)

    @el.css({
      top: top + @offset.top,
      left: left + @offset.left
    })

  destroy: () ->
    @target = null
    @active = false
    @editor.off('.linkpopover')
    @el.remove()
