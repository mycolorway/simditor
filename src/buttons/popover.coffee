
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

    #@editor.on 'blur.popover', =>
      #@target.addClass('selected') if @active and @target?

    @el.on 'mouseenter', (e) =>
      @el.addClass 'hover'
    @el.on 'mouseleave', (e) =>
      @el.removeClass 'hover'

  render: ->

  show: ($target, position = 'bottom') ->
    return unless $target?
    @editor.hidePopover()

    @target = $target.addClass('selected')

    if @active
      @refresh(position)
      @trigger 'popovershow'
    else
      @active = true

      @el.css({
        left: -9999
      }).show()

      setTimeout =>
        @refresh(position)
        @trigger 'popovershow'
      , 0

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

    left = Math.min(targetOffset.left - editorOffset.left, @editor.wrapper.width() - @el.outerWidth() - 10)

    @el.css({
      top: top + @offset.top,
      left: left + @offset.left
    })

  destroy: () ->
    @target = null
    @active = false
    @editor.off('.linkpopover')
    @el.remove()


Simditor.Popover = Popover
