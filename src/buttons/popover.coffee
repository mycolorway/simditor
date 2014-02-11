
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
      targetPos = @target.position()
      targetH = @target.outerHeight()

      if position is 'bottom'
        top = targetPos.top + targetH
      else if position is 'top'
        top = targetPos.top - @el.height()

      left = Math.min(targetPos.left, @editor.wrapper.width() - @el.width())

      @el.css({
        top: top + @offset.top + parseFloat(@editor.wrapper.css('padding-top')),
        left: left + @offset.left
      })

      @trigger 'popovershow'
    , 0

  hide: ->
    @target = null
    @active = false
    @el.hide()
    @trigger 'popoverhide'

  destroy: () ->
    @target = null
    @active = false
    @editor.off('.linkpopover')
    @el.remove()
